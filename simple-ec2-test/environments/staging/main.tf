# Staging Environment Configuration

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # S3 Backend Configuration for Remote State
  backend "s3" {
    bucket = "tf-state-bucket"
    key    = "simple-ec2-test/staging/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "staging"
      Project     = "simple-ec2-test"
      ManagedBy   = "terraform"
      Owner       = "staging-team"
    }
  }
}

# Call the EC2 Application Module
module "ec2_app" {
  source = "../../modules/ec2-app"

  project_name         = var.project_name
  environment          = var.environment
  aws_region          = var.aws_region
  instance_type       = var.instance_type
  key_name            = var.key_name
  allowed_cidr_blocks = var.allowed_cidr_blocks
  app_name            = "${var.project_name} - Staging"
  app_port            = var.app_port
  
  # Staging-specific VPC configuration
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  
  # Common tags
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Owner       = "staging-team"
  }
}