variable "ses_sender_email" {
  type = string
}

variable "ses_recipient_email" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "lambda_zip_file" {
  type = string
}
