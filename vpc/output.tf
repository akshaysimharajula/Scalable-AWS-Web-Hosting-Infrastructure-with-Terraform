output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_ids" {
  value = [
    aws_subnet.my_subnet.id,
    aws_subnet.my_subnet2.id
  ]
}

output "my_sg_out"{
value = aws_security_group.my_sg.id
}
