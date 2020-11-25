data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  zoneA            = data.aws_availability_zones.available.names[0]
  zoneB            = data.aws_availability_zones.available.names[1]
  zoneC            = data.aws_availability_zones.available.names[2]
}

resource "aws_vpc" "selected" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = true

  count = var.create_new_vpc == "true" ? 1 : 0

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
  }
}

##### PUBLIC SUBNETS #####

resource "aws_subnet" "public" {
  count                   = var.create_new_subnets == "true" ? 3 : 0
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.selected[0].id

  cidr_block = var.public_cidr_subnets[count.index]

  tags = map(
  "Name", "${var.cluster_name}-${data.aws_availability_zones.available.names[count.index]}",
  "Cluster", var.cluster_name, "Environment", var.env,
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.selected[0].id

  count = var.create_new_subnets == "true" ? 1 : 0

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
  }
}

resource "aws_route_table" "route_public" {
  vpc_id = aws_vpc.selected[0].id

  count = var.create_new_subnets == "true" ? 1 : 0

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw[0].id
  }

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
  }
}

resource "aws_route_table_association" "a_public" {
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.route_public[0].id

  count = var.create_new_subnets == "true" ? 1 : 0
}

resource "aws_route_table_association" "b_public" {
  subnet_id      = aws_subnet.public[1].id
  route_table_id = aws_route_table.route_public[0].id

  count = var.create_new_subnets == "true" ? 1 : 0
}

resource "aws_route_table_association" "c_public" {
  subnet_id      = aws_subnet.public[2].id
  route_table_id = aws_route_table.route_public[0].id

  count = var.create_new_subnets == "true" ? 1 : 0
}

##### PRIVATE SUBNETS #####

resource "aws_subnet" "private" {
  count                   = var.create_new_subnets == "true" ? 3 : 0
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.selected[0].id

  cidr_block = var.private_cidr_subnets[count.index]

  tags = map(
  "Name", "${var.cluster_name}-${data.aws_availability_zones.available.names[count.index]}",
  "Cluster", var.cluster_name, "Environment", var.env,
  )
}

resource "aws_eip" "nat_elp" {
  vpc      = true

  count = var.create_new_subnets == "true" ? 1 : 0

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat_elp[0].id
  subnet_id     = aws_subnet.public[2].id

  count = var.create_new_subnets == "true" ? 1 : 0

  tags = {
    Name = "gw NAT for private subnets"
    Environment = var.env
    Cluster     = var.cluster_name
  }
}

resource "aws_route_table" "route_private" {
  vpc_id = aws_vpc.selected[0].id

  count = var.create_new_subnets == "true" ? 1 : 0

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw[0].id
  }

  tags = {
    Environment = var.env
    Cluster     = var.cluster_name
  }
}

resource "aws_route_table_association" "a_private" {
  subnet_id      = aws_subnet.private[0].id
  route_table_id = aws_route_table.route_private[0].id

  count = var.create_new_subnets == "true" ? 1 : 0
}

resource "aws_route_table_association" "b_private" {
  subnet_id      = aws_subnet.private[1].id
  route_table_id = aws_route_table.route_private[0].id

  count = var.create_new_subnets == "true" ? 1 : 0
}

resource "aws_route_table_association" "c_private" {
  subnet_id      = aws_subnet.private[2].id
  route_table_id = aws_route_table.route_private[0].id

  count = var.create_new_subnets == "true" ? 1 : 0
}