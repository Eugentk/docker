resource "aws_vpc" "Application_VPC" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = merge(var.main_tags, {
    Name = "VPC ${var.main_tags["Environment"]}"
  })
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "aws-subnet-public-primary" {
  count             = length(var.subnet_public)
  vpc_id            = aws_vpc.Application_VPC.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.subnet_public[count.index]

  tags = merge(var.main_tags, {
    Name = "Public Subnet primary ${var.main_tags["Environment"]}-${count.index}"
    Tier = "Public"
  })
}
## Internet gateway

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.Application_VPC.id
  tags = {
    Name = "Internet gateway"
  }
}

#-------------------------------------------------------------------------------
#                                 Routing
#-------------------------------------------------------------------------------

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.Application_VPC.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

## Routing table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.Application_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

# Associate subnet public_subnet_primary to public route table

resource "aws_route_table_association" "public_subnet_primary_association" {
  count          = length(aws_subnet.aws-subnet-public-primary)
  subnet_id      = element(aws_subnet.aws-subnet-public-primary.*.id, count.index)
  route_table_id = aws_vpc.Application_VPC.main_route_table_id
}
