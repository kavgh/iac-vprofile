locals {
  tags = merge(var.tags, { Service = "vpc" })
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true

  tags = merge(local.tags, { Resource = "vpc" })
}

data "aws_availability_zones" "this" {}

#####################
### Public subnet ###
#####################

resource "aws_subnet" "public" {
  count = var.nos

  vpc_id               = aws_vpc.this.id
  cidr_block           = cidrsubnet(var.cidr_block, var.nos, count.index)
  availability_zone_id = data.aws_availability_zones.this.zone_ids[count.index]

  tags = merge(local.tags, { Resource = "pub_sub" })
}

resource "aws_route_table" "public" {
  count = length(aws_subnet.public)

  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, { Resource = "pub_rtb" })
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = element(aws_route_table.public[*].id, count.index)
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, { Resource = "igw" })
}

resource "aws_route" "this" {
  count = length(aws_route_table.public)

  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

######################
### Private Subnet ###
######################

resource "aws_subnet" "private" {
  count = var.nos

  vpc_id               = aws_vpc.this.id
  cidr_block           = cidrsubnet(var.cidr_block, var.nos, var.nos + count.index)
  availability_zone_id = data.aws_availability_zones.this.zone_ids[count.index]

  tags = merge(local.tags, { Resource = "priv_sub" })
}

resource "aws_route_table" "private" {
  count = length(aws_subnet.private)

  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, { Resource = "priv_rtb" })
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index)
}