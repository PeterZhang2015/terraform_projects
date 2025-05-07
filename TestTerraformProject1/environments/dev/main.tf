module "webserver" {
  source        = "..//../modules/webserver"
  ami           = var.ami_id
  instance_type = var.instance_type
  instance_tags = var.instance_tags
}
