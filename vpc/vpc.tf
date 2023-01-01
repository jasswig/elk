# Create new VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

# Public subnet 1
resource "aws_subnet" "public-1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone_id = "use1-az1"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-1A"
  }
}

# Public subnet 2
resource "aws_subnet" "public-1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone_id = "use1-az2"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-1B"
  }
}

# Private subnet 1
resource "aws_subnet" "private-1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone_id = "use1-az1"

  tags = {
    Name = "Private-1A"
  }
}

# Private subnet 2
resource "aws_subnet" "private-1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone_id = "use1-az2"

  tags = {
    Name = "Private-1B"
  }
}

# New route table for private subnet 1
resource "aws_route_table" "private-a" {
  vpc_id = aws_vpc.main.id

#   route = []

  tags = {
    Name = "Private-RT-a"
  }
}

# New route table for private subnet 2
resource "aws_route_table" "private-b" {
  vpc_id = aws_vpc.main.id

#   route = []

  tags = {
    Name = "Private-RT-b"
  }
}

# Associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.private-1a.id
  route_table_id = aws_route_table.private-a.id
}

# Associate subnet with route table
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.private-1b.id
  route_table_id = aws_route_table.private-b.id
}

# Add IGW & attach to the VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MyIGW"
  }
}

# Add route to internet gateway for public subnets
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public-RT"
  }
}

# Pre-req. for creating nat gateway, create a elastic ip
resource "aws_eip" "nat_gateway-a" {
  vpc = true
  tags = {
    "Name" = "MyEIP-a"
  }
  
}

# Nat gateway for egress traffic from private subents
resource "aws_nat_gateway" "gw-a" {
  allocation_id = aws_eip.nat_gateway-a.id
  subnet_id = aws_subnet.public-1a.id
  depends_on = [aws_internet_gateway.gw]
  tags = {
    "Name" = "MyNatG-a"
  }
}

resource "aws_eip" "nat_gateway-b" {
  vpc = true
  tags = {
    "Name" = "MyEIP-b"
  }
}

resource "aws_nat_gateway" "gw-b" {
  allocation_id = aws_eip.nat_gateway-b.id
  subnet_id = aws_subnet.public-1b.id
  depends_on = [aws_internet_gateway.gw]
  tags = {
    "Name" = "MyNatG-b"
  }
}

# Add route in route table for nat gateway (egress traffic)
resource "aws_route" "r-a" {
  route_table_id            = aws_route_table.private-a.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.gw-a.id
}

resource "aws_route" "r-b" {
  route_table_id            = aws_route_table.private-b.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.gw-b.id
}