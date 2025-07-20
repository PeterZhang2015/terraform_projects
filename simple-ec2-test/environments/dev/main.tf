# Development Environment Configuration
# Note: Backend and provider configurations are in backend.tf

# Call the EC2 Application Module
module "ec2_app" {
  source = "../../modules/ec2-app"

  project_name         = var.project_name
  environment          = var.environment
  aws_region          = var.aws_region
  instance_type       = var.instance_type
  key_name            = var.key_name
  allowed_cidr_blocks = var.allowed_cidr_blocks
  app_name            = "${var.project_name} - Development"
  app_port            = var.app_port
  
  # Development-specific VPC configuration
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  
  # Common tags
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Owner       = "dev-team"
  }
}