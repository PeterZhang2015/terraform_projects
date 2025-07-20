terraform {
  source = "../../../modules/ec2"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  ami_id        = "ami-12345678"
  instance_type = "t2.micro"
  vpc_id       = "vpc-12345678"
}