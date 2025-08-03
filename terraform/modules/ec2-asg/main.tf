resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name                    = "blogkey"


  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = var.private_subnet_ids[0]
    security_groups             = var.security_group_ids
  }
  metadata_options {
    http_tokens   = "required" # Enforces IMDSv2
    http_endpoint = "enabled"  # Optional; enables IMDS access
  }
  iam_instance_profile {
  name = aws_iam_instance_profile.ec2_ssm_profile.name
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name = "${var.name_prefix}-instance"
      },
      var.tags
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "this" {
  name                = "${var.name_prefix}-asg"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = var.target_group_arns
  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  # 👇 tags ثابتة عشان تقدر تعمل filter عليها
  tag {
    key                 = "Project"
    value               = "itvisionary"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "dev"
    propagate_at_launch = true
  }
  health_check_type = "EC2"
  force_delete      = true
}


# resource "aws_network_interface_attachment" "this" {
#   instance_id          = aws_autoscaling_group.this.instances[0]
#   network_interface_id = var.network_interface_id
#   device_index         = 1
#   depends_on           = [aws_autoscaling_group.this]
# }


resource "aws_iam_role" "ec2_ssm_role" {
  name = "EC2SSMRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:Environment"
    values = ["dev"]
  }

  filter {
    name   = "tag:Project"
    values = ["itvisionary"]
  }

 
  depends_on = [aws_autoscaling_group.this]
}