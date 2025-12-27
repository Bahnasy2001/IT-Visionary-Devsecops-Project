output "asg_name" {
  value = aws_autoscaling_group.this.name
}

output "launch_template_id" {
  value = aws_launch_template.this.id
}

output "private_subnet_ids" {
  value = var.private_subnet_ids
}

output "asg_instance_private_ips" {
  description = "Private IPs of EC2s in the ASG (with Project=itvisionary, Environment=dev)"
  value       = data.aws_instances.asg_instances.private_ips
}
