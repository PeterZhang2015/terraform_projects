# Outputs for Development Environment

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.ec2_app.vpc_id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_app.instance_id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_app.instance_public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = module.ec2_app.instance_public_dns
}

output "application_url" {
  description = "URL to access the application"
  value       = module.ec2_app.application_url
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${module.ec2_app.instance_public_ip}"
}