provider "aws" {
  region = "ap-northeast-1"
}

## VPC ##
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = format("%s-%s", var.cluster_name, "vpc")
  }
}

## SUBNET ##
# public subnet
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet1

  availability_zone = var.subnet_az1

  tags = {
    Name = format("%s-%s", var.cluster_name, "subnet1")
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet2

  availability_zone = var.subnet_az2

  tags = {
    Name = format("%s-%s", var.cluster_name, "subnet2")
  }
}
# private subnet
resource "aws_subnet" "subnet3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet3

  availability_zone = var.subnet_az3

  tags = {
    Name = format("%s-%s", var.cluster_name, "subnet3")
  }
}

resource "aws_subnet" "subnet4" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet4

  availability_zone = var.subnet_az4

  tags = {
    Name = format("%s-%s", var.cluster_name, "subnet4")
  }
}



## INTERNET GATEWAY ##
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s-%s", var.cluster_name, "igw")
  }
}

## ROUTE TABLE ##
#### route teable for public subnet
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s-%s", var.cluster_name, "rt")
  }
}

resource "aws_route_table_association" "my_rt_association1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "my_rt_association2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
#### route table for private subnet
resource "aws_route_table" "rt-rds" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s-%s", var.cluster_name, "rds")
  }
}

resource "aws_route_table_association" "my_rt_association3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.rt-rds.id
}

resource "aws_route_table_association" "my_rt_association4" {
  subnet_id      = aws_subnet.subnet4.id
  route_table_id = aws_route_table.rt-rds.id
}


## SECURITY GROUP ##
#### for ec2
resource "aws_security_group" "sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = format("%s-%s", var.cluster_name, "sg")
  description = "my default security group"
}

resource "aws_security_group_rule" "sg_inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "sg_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

#### for rds
resource "aws_security_group" "sg-rds" {
  vpc_id      = aws_vpc.vpc.id
  name        = format("%s-%s", var.cluster_name, "sg-rds")
  description = "SG - RDS"
}

resource "aws_security_group_rule" "rdssginbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-rds.id
}

resource "aws_security_group_rule" "rdssgoutbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-rds.id
}