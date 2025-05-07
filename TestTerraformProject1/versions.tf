terraform {
    required_version = ">=1.11.0"
    required_providers {
        source  = "aws"
        version = "~>1.14"
    }
    backend "s3" {
        bucket = "test-bucket"
        key    = "dev"
        region = "us-east-1"
    }
}
