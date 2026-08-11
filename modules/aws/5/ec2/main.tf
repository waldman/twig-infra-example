locals {
  base_name = "${var.environment}-${var.class}-${var.component}-${var.module}"
}

resource "aws_security_group" "this" {
  name        = local.base_name
  description = "Managed by terraform: ec2/${local.base_name}"
  vpc_id      = var.ec2_vpc_id
  tags        = merge(var.default_tags, { Name = local.base_name })
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each          = toset(var.ec2_ssh_ingress_cidr_blocks)
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = each.value
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  tags              = merge(var.default_tags, { Name = "${local.base_name}-ssh" })
}

resource "aws_vpc_security_group_ingress_rule" "extra" {
  count             = length(var.ec2_extra_ingress_rules)
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = var.ec2_extra_ingress_rules[count.index].cidr_blocks[0]
  from_port         = var.ec2_extra_ingress_rules[count.index].from_port
  to_port           = var.ec2_extra_ingress_rules[count.index].to_port
  ip_protocol       = var.ec2_extra_ingress_rules[count.index].protocol
  tags              = merge(var.default_tags, { Name = "${local.base_name}-extra-${count.index}" })
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  tags              = merge(var.default_tags, { Name = "${local.base_name}-egress" })
}

resource "aws_instance" "this" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.ec2_subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  key_name                    = var.ec2_key_name
  associate_public_ip_address = var.ec2_associate_public_ip
  user_data                   = var.ec2_user_data

  root_block_device {
    volume_size = var.ec2_root_volume_size_gb
    volume_type = "gp3"
    encrypted   = true
    tags        = merge(var.default_tags, { Name = "${local.base_name}-root" })
  }

  tags = merge(var.default_tags, { Name = local.base_name })
}
