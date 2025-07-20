terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = var.aws_region
}

remote_state {
    backend = "s3"
    config = {
        bucket         = "test-bucket"
        key            = "dev"
        region         = "us-east-1"
        encrypt        = true
        use_lockfile   = true
    }
}