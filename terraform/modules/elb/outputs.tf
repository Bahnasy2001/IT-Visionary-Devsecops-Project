output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "lb_target_group_arn" {
  value = aws_lb_target_group.this.arn
}
