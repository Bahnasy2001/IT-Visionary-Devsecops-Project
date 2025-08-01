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
###

name_prefix        = "itv-dev"
ami_id             = "ami-08a6efd148b1f7504"  
instance_type      = "t2.micro"
desired_capacity   = 2
min_size           = 1
max_size           = 3
tags = {
  Environment = "dev"
  Project     = "itvisionary"
}
target_type         = "instance"
