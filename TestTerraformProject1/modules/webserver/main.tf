resource "aws_instance" "web_server" {
    ami           = var.ami
    instance_type = var.instance_type
    tags = var.instance_tags
}
