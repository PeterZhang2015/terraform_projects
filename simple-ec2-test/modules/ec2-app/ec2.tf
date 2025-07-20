# User data script for the EC2 instance
locals {
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    app_port = var.app_port
  }))
}

# Create EC2 instance using terraform-aws-modules
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "${var.project_name}-${var.environment}-instance"

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [module.security_group.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  
  associate_public_ip_address = true
  
  user_data_base64 = local.user_data
  
  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 8
      encrypted   = true
      delete_on_termination = true
    }
  ]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-instance"
  })
}
