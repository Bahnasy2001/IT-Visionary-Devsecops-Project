variable "name" {
  type = string
}

variable "image_tag_mutability" {
  type = string
}

variable "force_delete" {
  type = bool
}

variable "encryption_type" {
  type = string
}

variable "scan_on_push" {
  type = bool
}

variable "tags" {
  type = map(string)
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

variable "security_group_id" {
  description = "Security group for the EC2 instance"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

######
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