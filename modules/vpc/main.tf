locals {
  tags = merge(var.tags, { Service = "vpc" })
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true

  tags = merge(local.tags, { Resource = "vpc" })
}

resource "aws_subnet" "public" {
    count = var.nos

    vpc_id = aws_vpc.this.id

    cidr_block = cidrsubnet(var.cidr_block, var.nos, count.index)

    tags = merge(local.tags, { Resource = "pub_sub" })
}

resource "aws_subnet" "private" {
    count = var.nos

  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(var.cidr_block, var.nos, var.nos + count.index )

  tags = merge(local.tags, { Resource = "priv_sub" })
}

