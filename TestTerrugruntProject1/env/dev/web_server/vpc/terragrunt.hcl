terraform {
  source = "../../../modules/vpc"
}

inputs = {
  cidr     = "10.0.0.0/16"
}