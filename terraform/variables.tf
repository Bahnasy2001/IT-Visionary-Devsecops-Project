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