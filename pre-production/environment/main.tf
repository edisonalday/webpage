# pre VPC resources

resource "aws_vpc"
"vpc_pre" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "PRE-VPC",
    Environment = "Development"
    VPC = "PRE"
    Purpose = "Pre-production VPC"
  }
}
resource "aws_subnet" "private_subnet_us-east-1a" {
  vpc_id = "${aws_vpc.vpc_pre.id}"
  cidr_block = "10.0.0.0/28"
  availability_zone = "us-east-1a"
  tags = {
    Name = "PRE-PRV-01A"
  }
}
resource "aws_subnet" "private_subnet_us-east-1b" {
  vpc_id = "${aws_vpc.vpc_pre.id}"
  cidr_block = "10.0.5.0/28"
  availability_zone = "us-east-1b"
  tags = {
    Name = "PRE-PRV-01B"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc_pre.id}"
  tags {
    Name = "PRE-VPC-IGW"
    }
}
resource "aws_route" "internet_access" {
  route_table_id = "${aws_vpc.vpc_pre.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw.id}"
}
resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.vpc_pre.id}"
    tags {
      Name = "PRE-PRV-RTB"
    }
}
resource "aws_route" "private_route" {
  route_table_id  = "${aws_route_table.private_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw.id}"
}
resource "aws_route_table_association" "private_subnet_us-east-1a_association" {
    subnet_id = "${aws_subnet.private_subnet_us-east-1a.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}
resource "aws_route_table_association" "private_subnet_us-east-1b_association" {
    subnet_id = "${aws_subnet.private_subnet_us-east-1b.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}


resource "aws_security_group"
"pre_ssh" {
description = "This security group allow SSH access to the servers inside the pre VPC."
tags = {
Name = "PRE-SYS-SSH-SG",
VPC = "PRE",
}

ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = [ "66.96.207.237/32", "81.47.160.42/32" ]
}

# Access to Internet for instance
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = [ "0.0.0.0/0" ]
}
vpc_id = "${aws_vpc.vpc_pre.id}"
}

resource "aws_security_group"
"pre_web" {
description = "This security group allow HTTP and HTTPS access to the servers inside the pre VPC."
tags = {
Name = "PRE-SRV-WEB-SG",
VPC = "PRE",
}

ingress {
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

# Access to Internet for instance
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = [ "0.0.0.0/0" ]
}

ingress {
from_port = 8080
to_port = 8080
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

# Access to Internet for instance
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = [ "0.0.0.0/0" ]
}
ingress {
from_port = 443
to_port = 443
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

# Access to Internet for instance
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = [ "0.0.0.0/0" ]
}
vpc_id = "${aws_vpc.vpc_pre.id}"
}





