locals {
  base_name = "${var.environment}-${var.class}-${var.component}-${var.module}"
}

resource "aws_instance" "this" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.ec2_subnet_id
  vpc_security_group_ids      = var.ec2_security_group_ids
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
