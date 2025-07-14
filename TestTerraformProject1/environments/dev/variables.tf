variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances."
  default     = "ami-830c94e3"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type test."
  default     = "t2.micro"
}

variable "instance_tags" {
  type        = map(string)
  description = "Tags for the EC2 instance."
  default = {
    Name        = "TestInstance"
    Environment = "development"
  }
}
