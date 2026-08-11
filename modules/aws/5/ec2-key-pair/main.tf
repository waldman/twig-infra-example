locals {
  key_name = "${var.environment}-${var.class}-${var.component}-${var.module}"
}

resource "aws_key_pair" "this" {
  key_name   = local.key_name
  public_key = var.ec2_key_pair_public_key
  tags       = var.default_tags
}
