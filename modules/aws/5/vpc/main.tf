data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  base_name = "${var.environment}-${var.class}-${var.component}-${var.module}"
  azs       = slice(data.aws_availability_zones.available.names, 0, var.vpc_availability_zones)

  # /24 subnets carved from the VPC CIDR. Public: 0..N-1, private: 100..100+N-1.
  # /16 + 8 newbits = /24 (256 IPs, 251 usable per subnet). newbits=8 lets
  # netnum go up to 255 — enough headroom for the +100 offset convention.
  public_cidrs  = [for i in range(var.vpc_availability_zones) : cidrsubnet(var.vpc_cidr_block, 8, i)]
  private_cidrs = [for i in range(var.vpc_availability_zones) : cidrsubnet(var.vpc_cidr_block, 8, i + 100)]

  # One NAT covers all private subnets when single_nat_gateway = true.
  nat_count = var.vpc_single_nat_gateway ? 1 : var.vpc_availability_zones
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.default_tags, {
    Name = local.base_name
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.default_tags, { Name = local.base_name })
}

resource "aws_subnet" "public" {
  count                   = var.vpc_availability_zones
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.default_tags, {
    Name = "${local.base_name}-public-${local.azs[count.index]}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  count             = var.vpc_availability_zones
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(var.default_tags, {
    Name = "${local.base_name}-private-${local.azs[count.index]}"
    Tier = "private"
  })
}

resource "aws_eip" "nat" {
  count  = local.nat_count
  domain = "vpc"
  tags   = merge(var.default_tags, { Name = "${local.base_name}-nat-${count.index}" })
}

resource "aws_nat_gateway" "this" {
  count         = local.nat_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(var.default_tags, { Name = "${local.base_name}-nat-${count.index}" })

  depends_on = [aws_internet_gateway.this]
}

# Public route table — one, shared across public subnets.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.default_tags, { Name = "${local.base_name}-public" })
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = var.vpc_availability_zones
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route tables — one per AZ. When single_nat_gateway, all point at the sole NAT.
resource "aws_route_table" "private" {
  count  = var.vpc_availability_zones
  vpc_id = aws_vpc.this.id
  tags   = merge(var.default_tags, { Name = "${local.base_name}-private-${local.azs[count.index]}" })
}

resource "aws_route" "private_default" {
  count                  = var.vpc_availability_zones
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.vpc_single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = var.vpc_availability_zones
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
