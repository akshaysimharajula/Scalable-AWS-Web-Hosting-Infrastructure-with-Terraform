variable "vpc_id" {

}

variable "subnet_ids" {
  type = list(string)
}
variable "my_sg_out" {}
variable "webserver_template" {}