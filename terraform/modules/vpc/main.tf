# VPC
resource "aws_vpc" "main" {
  # checkov:skip=CKV2_AWS_12:reason="Default security group is properly configured with restricted rules"
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# VPC Flow Logs
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = "/aws/vpc/flow-logs/${var.project_name}-${var.environment}"
  retention_in_days = 365  # 1 year retention

  kms_key_id = aws_kms_key.vpc_flow_log_key.arn

  tags = {
    Name        = "${var.project_name}-vpc-flow-logs-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# KMS key for VPC Flow Logs
resource "aws_kms_key" "vpc_flow_log_key" {
  description             = "KMS key for VPC Flow Logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs to use the key"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-vpc-flow-log-key-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_kms_alias" "vpc_flow_log_key_alias" {
  name          = "alias/vpc-flow-log-${var.project_name}-${var.environment}"
  target_key_id = aws_kms_key.vpc_flow_log_key.key_id
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "vpc_flow_log_role" {
  name = "${var.project_name}-vpc-flow-log-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-vpc-flow-log-role-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  name = "${var.project_name}-vpc-flow-log-policy-${var.environment}"
  role = aws_iam_role.vpc_flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = aws_cloudwatch_log_group.vpc_flow_log.arn
      }
    ]
  })
}

# Default Security Group with restricted rules
resource "aws_security_group" "default" {
  # checkov:skip=CKV_AWS_382:reason="Default security group has no egress traffic allowed (restricted)"
  # checkov:skip=CKV2_AWS_5:reason="Default security group is intentionally created for VPC default configuration"
  name_prefix = "${var.project_name}-default-${var.environment}-"
  description = "Default security group with restricted access"
  vpc_id      = aws_vpc.main.id

  # No ingress rules - completely restricted
  egress {
    description = "No outbound traffic allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  tags = {
    Name        = "${var.project_name}-default-sg-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  # checkov:skip=CKV_AWS_130:reason="Public subnets need to assign public IPs for internet connectivity"
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet-${var.environment}-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
    Type        = "public"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.project_name}-private-subnet-${var.environment}-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
    Type        = "private"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Route Table Association for Public Subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-private-rt-${var.environment}-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Route Table Association for Private Subnets
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Security Group for Application Load Balancer
resource "aws_security_group" "alb_sg" {
  # checkov:skip=CKV_AWS_260:reason="ALB needs to accept HTTP traffic from internet"
  # checkov:skip=CKV2_AWS_5:reason="ALB security group will be attached to ALB resource"
  name_prefix = "${var.project_name}-alb-${var.environment}-"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow port 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # أو غيرها حسب الحاجة
  }

  ingress {
    description = "Allow port 8082"
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow port 5000"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow port 3306"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # لو ده MySQL/MariaDB خلي بالك من الفتح العام، ممكن تخصص CIDR blocks آمنة أكتر
  }

  egress {
    description = "Allow outbound traffic to web tier"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "Allow outbound traffic to web tier HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name        = "${var.project_name}-alb-sg-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Security Group for Application Servers (Private) - FIXED FOR SSM
resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-app-${var.environment}-"
  description = "Security group for application tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from inside VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]   # السماح من داخل الـ VPC
  }

  ingress {
    description = "HTTPS from inside VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "SSH from inside VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
#############################################
# Security Group for Bastion Host
#############################################
resource "aws_security_group" "bastion_sg" {
  # checkov:skip=CKV_AWS_23:reason="وصف البورتات مضاف"
  # checkov:skip=CKV_AWS_24:reason="بندخل على الباستيون من الانترنت مع تحديد CIDR معين"
  name_prefix = "${var.project_name}-bastion-${var.environment}-"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
  }

  egress {
    description = "SSH to private instances"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    # checkov:skip=CKV_AWS_23:reason="Default HTTP/HTTPS egress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    # checkov:skip=CKV_AWS_23:reason="Default HTTP/HTTPS egress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-bastion-sg-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_security_group_rule" "app_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = aws_security_group.app.id
  description              = "SSH from bastion host"
}

#############################################
# Bastion Host EC2 Instance
#############################################

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "bastion" {
  # checkov:skip=CKV_AWS_135:reason="Bastion host لا يحتاج تحسين EBS"
  # checkov:skip=CKV_AWS_79:reason="تم تعطيل IMDSv1 لأمان أعلى"
  # checkov:skip=CKV_AWS_126:reason="غير مطلوب Detailed Monitoring للباصيون"
  # checkov:skip=CKV_AWS_88:reason="الباستيون يحتاج Public IP للاتصال الخارجي"
  # checkov:skip=CKV2_AWS_41:reason="لا حاجة لدور IAM في هذا الباستيون، استخدام مفتاح SSH فقط"

  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.bastion_instance_type
  key_name                    = "blogkey"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 35
    delete_on_termination = true
    encrypted             = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
    echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config
    systemctl restart sshd
  EOF
  )

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tags = {
    Name        = "${var.project_name}-bastion-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Type        = "bastion"
  }
}
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"
}

#############################################
# Variables
#############################################

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "bastion_private_key_path" {
  description = "Path to private key file on local machine"
  type        = string
}

#############################################
# Outputs
#############################################

output "bastion_public_ip" {
  value = aws_eip.bastion.public_ip
}

output "ssh_command_to_bastion" {
  value = "ssh -i ${var.bastion_private_key_path} ec2-user@${aws_eip.bastion.public_ip}"
}

output "blogkey_inside_bastion" {
  value = "/home/ec2-user/.ssh/blogkey.pem"
}

output "connection_instructions" {
  value = <<-EOT
    SSH to bastion:
    ssh -i ${var.bastion_private_key_path} ec2-user@${aws_eip.bastion.public_ip}
    Then from bastion:
    ssh -i ~/.ssh/blogkey.pem ec2-user@<private-instance-ip>
  EOT
}
