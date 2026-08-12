locals {
  base_name = "${var.environment}-${var.class}-${var.component}-${var.module}"
}

resource "aws_security_group" "this" {
  name        = local.base_name
  description = coalesce(var.sg_description, "Managed by terraform: ${local.base_name}")
  vpc_id      = var.sg_vpc_id
  tags        = merge(var.default_tags, { Name = local.base_name })
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  count             = length(var.sg_ingress_rules)
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = var.sg_ingress_rules[count.index].cidr_blocks[0]
  from_port         = var.sg_ingress_rules[count.index].from_port
  to_port           = var.sg_ingress_rules[count.index].to_port
  ip_protocol       = var.sg_ingress_rules[count.index].protocol
  tags              = merge(var.default_tags, { Name = "${local.base_name}-ingress-${count.index}" })
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  tags              = merge(var.default_tags, { Name = "${local.base_name}-egress-all" })
}
