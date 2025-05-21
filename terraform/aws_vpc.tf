resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.31.1.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.31.2.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "public_b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.31.3.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.31.4.0/24"
  availability_zone = "us-east-2b"
}

resource "aws_route_table" "route_table_a_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = aws_subnet.public_a.cidr_block
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table" "route_table_a_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = aws_subnet.private_a.cidr_block
    gateway_id = "local"
  }
}

resource "aws_route_table" "route_table_b_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = aws_subnet.public_b.cidr_block
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table" "route_table_b_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = aws_subnet.private_b.cidr_block
    gateway_id = "local"
  }
}
