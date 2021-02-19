# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "mediawiki-vpc"
    Automation = "Terraform"
  }
}

# Create Public Subnets
resource "aws_subnet" "subnet-public" {
  count = "${length(var.public_cidr_block)}"
  availability_zone = "${element(var.availability_zone, count.index)}"
  cidr_block = "${element(var.public_cidr_block, count.index)}"
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "mediawiki-public-subnet-${count.index}"
    Automation = "Terraform"
  }
}

# Create Private Subnet
resource "aws_subnet" "subnet-private" {
  availability_zone = "${var.availability_zone[0]}"
  cidr_block = "${var.private_cidr_block}"
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "mediawiki-private-subnet"
    Automation = "Terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "mediawiki-internet-gateway"
    Automation = "Terraform"
  }
}

# Route Table - Public Subnet
resource "aws_route_table" "public-route-table" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags = {
    Name = "mediawiki-public-route-table"
    Automation = "Terraform"
  }
}


# Attach Internet Gateway to Public Subnet
resource "aws_route_table_association" "ig-association" {
  count = "${length(aws_subnet.subnet-public.*.id)}"
  route_table_id = "${aws_route_table.public-route-table.id}"
  subnet_id = "${element(aws_subnet.subnet-public.*.id, count.index)}"
}

# Elastic IP
resource "aws_eip" "elasticip" {
  vpc = true
}

# NAT Gateway
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.elasticip.id}"
  subnet_id = "${aws_subnet.subnet-public[0].id}"
  tags = {
    Name = "mediawiki-nat-gateway"
    Automation = "Terraform"
  }
}

# Route Table - Private Subnet
resource "aws_route_table" "private-route-table" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat-gw.id}"
  }

  tags = {
    Name = "mediawiki-private-route-table"
    Automation = "Terraform"
  }
}

# Associate Public Route Table with public subnet
resource "aws_route_table_association" "ng-association-public" {
  count = "${length(aws_subnet.subnet-public.*.id)}"
  route_table_id = "${aws_route_table.public-route-table.id}"
  subnet_id = "${element(aws_subnet.subnet-public.*.id, count.index)}"
}

# Associate Private Route Table with private subnet
resource "aws_route_table_association" "ng-association-private" {
  route_table_id = "${aws_route_table.private-route-table.id}"
  subnet_id = "${aws_subnet.subnet-private.id}"
}


# Key pair generation
resource "tls_private_key" "sshkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "pemkey" {
  key_name   = "mediawiki-key"
  public_key = "${tls_private_key.sshkey.public_key_openssh}"
}

# Download newly created key pair
resource "local_file" "download_cloud_pem" {
  filename = "${path.root}/../ansible/mediawiki-key.pem"
  content = "${tls_private_key.sshkey.private_key_pem}"
}



