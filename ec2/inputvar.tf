variable "ami" {
    default ="ami-05cef57fad40b2755"
}
variable "instance"{
    default="t3.micro"
}

variable "keyname"{
    default="TF_key"
}

variable "vpc_id" {}

variable "subnet_ids" {
  type = list(string)
}

variable "my_sg_out" {}
