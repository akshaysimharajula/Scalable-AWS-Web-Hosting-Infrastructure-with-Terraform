resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "tfkey"
}

resource "aws_launch_template" "webserver_template" {
  
  image_id      = var.ami
  instance_type = var.instance
  key_name      = var.keyname
      network_interfaces {
    device_index                = 0
    subnet_id                   = var.subnet_ids[0]  
    security_groups             = [var.my_sg_out]       
    associate_public_ip_address = true
  }
user_data = base64encode(file("${path.module}/user_data.sh"))


  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "WebServer-from-LaunchTemplate"
    }
  }
}
