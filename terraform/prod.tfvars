name                 = "itvisionary-ecr-prod"
image_tag_mutability = "IMMUTABLE"
force_delete         = false
encryption_type      = "AES256"
scan_on_push         = true
tags = {
  Environment = "prod"
  Project     = "itvisonary"
}
ses_sender_email    = "ahmedrafat530@gmail.com"
ses_recipient_email = "ahmedrafat530@gmail.com"
aws_region          = "us-east-1"
