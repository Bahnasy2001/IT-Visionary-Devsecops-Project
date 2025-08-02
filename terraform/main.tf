terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket         = "it-visionary-devsecops-project"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

module "ec2_asg" {
  source = "./modules/ec2-asg"

  name_prefix        = var.name_prefix
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  desired_capacity   = var.desired_capacity
  min_size           = var.min_size
  max_size           = var.max_size
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_ids = [module.vpc.security_group_ids.app]
  target_group_arns = [module.elb.lb_target_group_arn]
  tags               = var.tags
  
}

module "elb" {
  source             = "./modules/elb"
  name_prefix        = var.name_prefix
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_ids = [module.vpc.security_group_ids.alb]
  target_type        = var.target_type
  tags               = var.tags
}


module "ecr" {
  for_each = var.ecr_repos

  source               = "./modules/ecr"
  name                 = each.key
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete
  encryption_type      = each.value.encryption_type
  scan_on_push         = each.value.scan_on_push
  tags                 = each.value.tags
}

module "notify_lambda" {
  source              = "./modules/notify-lambda"
  ses_sender_email    = var.ses_sender_email
  ses_recipient_email = var.ses_recipient_email
  aws_region          = var.aws_region
  lambda_zip_file     = "function.zip"


}
#network 
provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  aws_region           = var.aws_region
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr_block       = var.vpc_cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "security_group_ids" {
  description = "Map of security group IDs"
  value       = module.vpc.security_group_ids
}
