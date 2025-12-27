variable "name_prefix" {
  description = "Prefix for ALB naming"
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

variable "vpc_id" {
  description = "VPC ID where the ALB will be created"
  type        = string
} 

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the ALB"
 
}

