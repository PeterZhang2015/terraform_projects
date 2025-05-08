module "webserver" {
  source        = "..//../modules/webserver"
  ami           = var.ami_id
  instance_type = var.instance_type
  tags          = var.instance_tags
}
