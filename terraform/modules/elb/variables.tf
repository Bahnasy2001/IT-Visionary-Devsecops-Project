variable "name_prefix" {
  description = "Prefix for ALB naming"
  type        = string
}

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

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}


variable "lb_logging_bucket" {
  description = "S3 bucket for ALB access logs"
  type        = string
}

