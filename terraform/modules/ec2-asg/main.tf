resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = var.private_subnet_ids[0]
    security_groups             = var.security_group_ids
  }
  metadata_options {
    http_tokens   = "required" # Enforces IMDSv2
    http_endpoint = "enabled"  # Optional; enables IMDS access
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

  target_group_arns = [
    aws_lb_target_group.this.arn
  ]

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
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


