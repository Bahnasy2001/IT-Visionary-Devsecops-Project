ecr_repos = {
  ui = {
    image_tag_mutability = "MUTABLE"
    force_delete         = false
    encryption_type      = "AES256"
    scan_on_push         = true
    tags = {
      Environment = "dev"
      Project     = "itvisonary"
    }
  }
  auth = {
    image_tag_mutability = "MUTABLE"
    force_delete         = false
    encryption_type      = "AES256"
    scan_on_push         = true
    tags = {
      Environment = "dev"
      Project     = "itvisonary"
    }
  }
  weather = {
    image_tag_mutability = "MUTABLE"
    force_delete         = false
    encryption_type      = "AES256"
    scan_on_push         = true
    tags = {
      Environment = "dev"
      Project     = "itvosionary"
    }
  }
}

# Default Configuration 
aws_region = "us-east-1"
project_name = "my-project"
environment = "dev"
vpc_cidr_block = "10.0.0.0/16"

# Subnet configurations
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

availability_zones = ["us-east-1a", "us-east-1b"] 

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
target_type         = "instance"


