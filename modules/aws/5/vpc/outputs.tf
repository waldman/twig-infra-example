output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "first_public_subnet_id" {
  value = aws_subnet.public[0].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "availability_zones" {
  value = local.azs
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.this[*].id
}
