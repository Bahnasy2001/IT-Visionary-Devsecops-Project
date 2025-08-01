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
