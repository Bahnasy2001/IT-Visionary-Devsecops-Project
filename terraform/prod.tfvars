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

###
name_prefix        = "itv-prod"
ami_id             = "ami-08a6efd148b1f7504"  
instance_type      = "t2.micro"
desired_capacity   = 2
min_size           = 1
max_size           = 3
target_type         = "instance"

#network 

# Default Configuration 
aws_region = "us-east-1"
project_name = "my-project"
environment = "dev"
vpc_cidr_block = "10.0.0.0/16"

# Subnet configurations
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

availability_zones = ["us-east-1a", "us-east-1b"] 
#network 
vpc_id              = module.vpc.vpc_id
public_subnet_ids   = module.vpc.public_subnet_ids
private_subnet_ids  = module.vpc.private_subnet_ids
security_group_id   = module.security_group.security_group_id

