terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
  private_subnet_id  = var.private_subnet_id
  security_group_id  = var.security_group_id
  tags               = var.tags
}

module "elb" {
  source             = "./modules/elb"
  name_prefix        = var.name_prefix
  vpc_id             = var.vpc_id
  public_subnet_ids  = var.public_subnet_ids
  security_group_id  = var.security_group_id
  lb_logging_bucket  = var.lb_logging_bucket
  target_type        = var.target_type
  tags               = var.tags
}


module "ecr" {
  source = "./modules/ecr"

  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete
  encryption_type      = var.encryption_type
  scan_on_push         = var.scan_on_push
  tags                 = var.tags
}

module "notify_lambda" {
  source             = "./modules/notify-lambda"
  ses_sender_email   = var.ses_sender_email
  ses_recipient_email= var.ses_recipient_email
  aws_region         = var.aws_region
  lambda_zip_file    = "function.zip"
}
