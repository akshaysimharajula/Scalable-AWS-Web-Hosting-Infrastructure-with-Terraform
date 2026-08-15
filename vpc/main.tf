
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyCustomVPC"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyIGW"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "MyPublicSubnet"
  }
}


data "aws_route_tables" "main" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.my_vpc.id]
  }

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

resource "aws_route_table_association" "main_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = data.aws_route_tables.main.ids[0]
}

resource "aws_route" "default_route" {
    route_table_id         = data.aws_route_tables.main.ids[0]
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.my_igw.id
  }

resource "aws_security_group" "my_sg" {
  name        = "allow_http_ssh"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  # Outbound Rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = "Allow-HTTP-SSH"
  }
}

resource "aws_subnet" "my_subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "MyPublicSubnet2"
  }
}

resource "aws_route_table" "route2" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "route_table2"
  }
}

resource "aws_route_table_association" "subnet2_association" {
  subnet_id      = aws_subnet.my_subnet2.id
  route_table_id = aws_route_table.route2.id
}