variable "ecr_repos" {
  description = "Map of ECR repos and settings"
  type = map(object({
    image_tag_mutability = string
    force_delete         = bool
    encryption_type      = string
    scan_on_push         = bool
    tags                 = map(string)
  }))
}

variable "ses_recipient_email" {
  description = "Email address of the SES recipient"
  type        = string
}

variable "ses_sender_email" {
  description = "Email address of the SES sender"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

###
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t2.micro"
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "private_subnet_id" {
  description = "Private subnet where EC2 will be deployed"
  type        = string
}

######

variable "vpc_id" {
  description = "VPC ID for ALB and TG"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group to associate with the ALB"
  type        = string
}

variable "target_type" {
  description = "Type of target (instance or ip)"
  type        = string
  default     = "instance"
}



variable "lb_logging_bucket" {
  description = "S3 bucket for ALB access logs"
  type        = string
}

#network 
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "my-project"
}

variable "environment" {
  description = "Environment name (dev, staging, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
} 
