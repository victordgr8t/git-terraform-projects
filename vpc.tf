#create a VPC and define the ip range
resource "aws_vpc" "prod_vpc" {
  cidr_block           = "10.0.0.0/16" #ip range for the vpc
  enable_dns_hostnames = true          #gives you internal host name

  tags = {
    Name = "Production_VPC"
  }
}

#create public subnet
resource "aws_subnet" "prod_public_subnet" {
  depends_on = [aws_vpc.prod_vpc]

  vpc_id                  = aws_vpc.prod_vpc.id
  availability_zone       = lookup(var.awsprops, "az1")
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true #connect public subnet to the internet

  tags = {
    Name = "Public_Subnet_PROD"
  }
}

#create private subnet
resource "aws_subnet" "prod_private_subnet" {
  depends_on = [aws_vpc.prod_vpc]

  vpc_id            = aws_vpc.prod_vpc.id
  availability_zone = lookup(var.awsprops, "az2")
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "Private_Subnet_PROD"
  }
}

#create an internet gateway for the vpc
resource "aws_internet_gateway" "prod_igw" {
  depends_on = [aws_vpc.prod_vpc]
  vpc_id     = aws_vpc.prod_vpc.id
  tags = {
    Name = "prod-igw"
  }
}

#create a route table which targets the internet gateway
resource "aws_route_table" "prod_igw_rt" {
  depends_on = [aws_vpc.prod_vpc,
  aws_internet_gateway.prod_igw]

  vpc_id = aws_vpc.prod_vpc.id

  #set default ipv4 route to use the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_igw.id
  }
  tags = {
    Name = "Prod-Route-Table"
  }
}

#here we create the route table association to the Public subnet
resource "aws_route_table_association" "associate_prod_rt_public_subnet" {
  depends_on = [aws_subnet.prod_public_subnet,
  aws_route_table.prod_igw_rt]

  subnet_id      = aws_subnet.prod_public_subnet.id
  route_table_id = aws_route_table.prod_igw_rt.id
}
