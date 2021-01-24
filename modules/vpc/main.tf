/**
 * VPC
 */

resource "aws_vpc" "main_vpc" {
  cidr_block                       = var.vpc_cidr
  instance_tenancy                 = var.tenancy
  enable_dns_hostnames             = var.dns_hostnames
  enable_classiclink               = var.classic_link
  enable_dns_support               = var.dns_support
  enable_classiclink_dns_support   = var.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6
  tags                             = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.tags,
  )
}
/**
 * Subnets
 */
resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.main_vpc.id
  count             = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  cidr_block        = lookup(var.private_subnets[count.index], "cidr")
  availability_zone = lookup(var.private_subnets[count.index], "az")
  tags              = merge(
    { 
      "Name" = "${var.vpc_name}-pvt_sub_${count.index + 1}" 
    },
    var.tags,
  )
}

resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.main_vpc.id
  count                   = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  cidr_block              = lookup(var.public_subnets[count.index], "cidr")
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = lookup(var.public_subnets[count.index], "az")
  tags              = merge(
    { 
      "Name" = "${var.vpc_name}-pub_sub_${count.index + 1}"
    },
    var.tags,
  )
}

/**
 * Gateway
 */
resource "aws_internet_gateway" "main_gateway" {
  vpc_id     = aws_vpc.main_vpc.id
  count      = length(var.public_subnets) > 0 || var.create_ig == true ? 1 : 0
  tags              = merge(
    { 
      "Name" = "${var.vpc_name}-ig_${count.index + 1}"
    },
    var.tags,
  )
}

resource "aws_eip" "main_eip" {
  count      = length(var.private_subnets) > 0 || var.create_eip == true ? 1 : 0
  vpc        = true
  tags       = merge(
    { 
      "Name" = "${var.vpc_name}-eip_${count.index + 1}"
    },
    var.tags,
  )
}
resource "aws_nat_gateway" "main_natgateway" {
  count         = length(var.private_subnets) > 0 || var.create_nat_gateway == true ? 1 : 0
  allocation_id = aws_eip.main_eip[count.index].id
  subnet_id     = element(aws_subnet.public_subnets.*.id, 1)
  depends_on    = [aws_internet_gateway.main_gateway, aws_subnet.public_subnets]
  tags              = merge(
    { 
      "Name" = "${var.vpc_name}-nat_${count.index + 1}"
    },
    var.tags,
  )
}
/**
 * Route Tables
 */
resource "aws_route_table" "public_route_table" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
  tags              = merge(
    { 
      "Name" = "${var.vpc_name}-pub-rt_${count.index + 1}"
    },
    var.tags,
  )
}
resource "aws_route" "Public_route" {
  count                  = length(var.public_subnets) > 0 ? 1 : 0
  route_table_id         = aws_route_table.public_route_table[count.index].id
  destination_cidr_block = var.destination_cidr_block
  gateway_id             = aws_internet_gateway.main_gateway[count.index].id
}

resource "aws_route_table" "private_route_table" {
  count  = length(var.private_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
  tags              = merge(
    { 
      "Name" = "${var.vpc_name}-pvt-rt_${count.index + 1}"
    },
    var.tags,
  )
}
resource "aws_route" "private_route" {
  count                  = length(var.private_subnets) > 0 ? 1 : 0
  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = var.destination_cidr_block
  nat_gateway_id         = aws_nat_gateway.main_natgateway[count.index].id
}
/**
 * Route associations
 */
resource "aws_route_table_association" "pvt-rt-association" {
  count          = length(var.private_subnets) > 0 ? 1 : 0
  subnet_id      = aws_subnet.private_subnets.*.id
  route_table_id = aws_route_table.private_route_table.*.id[count.index]
}

resource "aws_route_table_association" "pub-rt-association" {
  count          = length(var.public_subnets) > 0 ? 1 : 0
  subnet_id      = aws_subnet.public_subnets.*.id[count.index]
  route_table_id = aws_route_table.public_route_table.*.id[count.index]
}


resource "aws_default_security_group" "main" {
  count = var.manage_default_security_group ? 1 : 0

  vpc_id = aws_vpc.main_vpc.id

  dynamic "ingress" {
    for_each = var.default_security_group_ingress
    content {
      self             = lookup(ingress.value, "self", null)
      cidr_blocks      = compact(split(",", lookup(ingress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(ingress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(ingress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(ingress.value, "security_groups", "")))
      description      = lookup(ingress.value, "description", null)
      from_port        = lookup(ingress.value, "from_port", 0)
      to_port          = lookup(ingress.value, "to_port", 0)
      protocol         = lookup(ingress.value, "protocol", "-1")
    }
  }

  dynamic "egress" {
    for_each = var.default_security_group_egress
    content {
      self             = lookup(egress.value, "self", null)
      cidr_blocks      = compact(split(",", lookup(egress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(egress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(egress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(egress.value, "security_groups", "")))
      description      = lookup(egress.value, "description", null)
      from_port        = lookup(egress.value, "from_port", 0)
      to_port          = lookup(egress.value, "to_port", 0)
      protocol         = lookup(egress.value, "protocol", "-1")
    }
  }

  tags = merge(
    {
      "Name" = format("%s", "${var.vpc_name}-default-sg")
    },
    var.tags,  
  )
}