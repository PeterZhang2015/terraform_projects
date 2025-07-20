variable "vpc_id" {
  type        = string
  description = "ID of the VPC to launch the instance in"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet to launch the instance in"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 instances to create"
  default     = 1
}

variable "instance_tags" {
  type        = map(string)
  description = "Tags for the EC2 instance"
}