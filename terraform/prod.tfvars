ecr_repos = {
  ui = {
    image_tag_mutability = "MUTABLE"
    force_delete         = false
    encryption_type      = "AES256"
    scan_on_push         = true
    tags = {
      Environment = "prod"
      Project     = "itvisonary"
    }
  }
  auth = {
    image_tag_mutability = "MUTABLE"
    force_delete         = false
    encryption_type      = "AES256"
    scan_on_push         = true
    tags = {
      Environment = "prod"
      Project     = "itvisonary"
    }
  }

  weather = {
    image_tag_mutability = "MUTABLE"
    force_delete         = false
    encryption_type      = "AES256"
    scan_on_push         = true
    tags = {
      Environment = "prod"
      Project     = "itvisonary"
    }
  }
}

ses_sender_email    = "ahmedrafat530@gmail.com"
ses_recipient_email = "ahmedrafat530@gmail.com"
aws_region          = "us-east-1"

###
name_prefix      = "itv-prod"
ami_id           = "ami-08a6efd148b1f7504"
instance_type    = "t2.micro"
desired_capacity = 2
min_size         = 1
max_size         = 3
target_type      = "instance"