# Configure data availability_zone
data "aws_availability_zones" "available" {}

# configuring vpc
resource "aws_vpc" "app_vpc" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "${var.instance_tenancy}"

  tags {
    Name = "app_vpc"
  }
}

# configuring public subnet
resource "aws_subnet" "public_subnet" {
  count                   = "${length(var.public_subnet_cidr)}"
  vpc_id                  = "${aws_vpc.app_vpc.id}"
  cidr_block              = "${var.public_subnet_cidr[count.index]}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = "true"

  tags {
    Name = "public_subnet${count.index+1}"
  }
}

# configuring private subnet
resource "aws_subnet" "private_subnet" {
  count             = "${length(var.private_subnet_cidr)}"
  vpc_id            = "${aws_vpc.app_vpc.id}"
  cidr_block        = "${var.private_subnet_cidr[count.index]}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags {
    Name = "private_subnet${count.index+1}"
  }
}

# Configuring internet gateway
resource "aws_internet_gateway" "app_igw" {
  vpc_id = "${aws_vpc.app_vpc.id}"

  tags {
    Name = "app_igw"
  }
}

# Configuring public Route table
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.app_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.app_igw.id}"
  }

  tags {
    Name = "public_route_table"
  }
}

# Configure private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.app_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.app_nat_gw.id}"
  }

  tags {
    Name = "private_route_table"
  }
}

# Configuring public Route Table association
resource "aws_route_table_association" "pub_sub_route_asso" {
  count          = "${length(var.public_subnet_cidr)}"
  subnet_id      = "${aws_subnet.public_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

# Configuring private route table association
resource "aws_route_table_association" "pri_sub_route_asso" {
  count          = "${length(var.private_subnet_cidr)}"
  subnet_id      = "${aws_subnet.private_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

#Configuring elastic ip
resource "aws_eip" "natgateway_eip" {
  vpc = true
}

#configuring NAT gateway
resource "aws_nat_gateway" "app_nat_gw" {
  allocation_id = "${aws_eip.natgateway_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.id}"

  tags {
    Name = "NAT_gateway"
  }
}
