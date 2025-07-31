terraform {
  backend "s3" {
    bucket         = "it-visionary-devsecops-project"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
