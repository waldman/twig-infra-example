locals {
  base_name  = "${var.environment}-${var.class}-${var.component}-${var.module}"
  table_name = var.dynamodb_table_name != null ? var.dynamodb_table_name : local.base_name
}

resource "aws_dynamodb_table" "this" {
  name         = local.table_name
  billing_mode = var.dynamodb_billing_mode
  hash_key     = var.dynamodb_hash_key

  attribute {
    name = var.dynamodb_hash_key
    type = var.dynamodb_hash_key_type
  }

  dynamic "ttl" {
    for_each = var.dynamodb_ttl_enabled ? [1] : []
    content {
      attribute_name = var.dynamodb_ttl_attribute
      enabled        = true
    }
  }

  tags = merge(var.default_tags, {
    Name = local.table_name
  })
}
