terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # S3 backend configuration for state management with S3 Object Lock
  backend "s3" {
    bucket         = "your-terraform-state-bucket-name"  # Replace with your unique bucket name
    key            = "simple-ec2-test/staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true  # Use S3 Object Lock instead of DynamoDB for state locking
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment   = var.environment
      Project       = var.project_name
      ManagedBy     = "Terraform"
      Repository    = "simple-ec2-test"
      CostCenter    = "Staging"
    }
  }
}