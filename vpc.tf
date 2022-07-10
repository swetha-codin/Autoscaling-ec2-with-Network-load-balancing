data "aws_availability_zones" "all" {}

# --------------------------------------------------------------------------------------------------------------------
# CREATE VPC
# --------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "codinlb-VPC" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "lb-VPC"
  }
}

# --------------------------------------------------------------------------------------------------------------------
# CREATE SUBNET
# --------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "lb-Subnet1" {
  vpc_id                  = "${aws_vpc.codinlb-VPC.id}"
  availability_zone       = "us-east-2a"
  cidr_block              = var.cidr_block1
  map_public_ip_on_launch = "false"
}
resource "aws_subnet" "lb-Subnet2" {
  vpc_id                  = "${aws_vpc.codinlb-VPC.id}"
  availability_zone       = "us-east-2b"
  cidr_block              = var.cidr_block2
  map_public_ip_on_launch = "false"
}
resource "aws_subnet" "lb-Subnet3" {
  vpc_id                  = "${aws_vpc.codinlb-VPC.id}"
  availability_zone       = "us-east-2c"
  cidr_block              = var.cidr_block3
  map_public_ip_on_launch = "false"
}
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.codinlb-VPC.id}"

  tags = {
    Name = "codin-IGW"
  }
}

# --------------------------------------------------------------------------------------------------------------------
# CREATE ROUTE TABLE
# --------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "codin-RouteTable-Private" {
  vpc_id = "${aws_vpc.codinlb-VPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "VPS1" {
  subnet_id      = aws_subnet.lb-Subnet1.id 
  route_table_id = aws_route_table.codin-RouteTable-Private.id
}
resource "aws_route_table_association" "VPS2" {
  subnet_id      = aws_subnet.lb-Subnet2.id
  route_table_id = aws_route_table.codin-RouteTable-Private.id
}
resource "aws_route_table_association" "VPS3" {
  subnet_id      = aws_subnet.lb-Subnet3.id 
  route_table_id = aws_route_table.codin-RouteTable-Private.id
}