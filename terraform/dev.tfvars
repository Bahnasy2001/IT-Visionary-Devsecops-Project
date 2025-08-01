name                 = "itvisionary-ecr-dev"
image_tag_mutability = "MUTABLE"
force_delete         = false
encryption_type      = "AES256"
scan_on_push         = true
tags = {
  Environment = "dev"
  Project     = "itvisionary"
}
ses_sender_email    = "ahmedrafat530@gmail.com"
ses_recipient_email = "ahmedrafat530@gmail.com"
aws_region          = "us-east-1"
