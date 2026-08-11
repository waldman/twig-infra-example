locals {
  policy_name = "${var.environment}-${var.class}-${var.component}-${var.module}"
}

data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = var.iam_policy_statements
    content {
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_policy" "this" {
  name   = local.policy_name
  policy = data.aws_iam_policy_document.this.json
  tags   = var.default_tags
}

resource "aws_iam_user_policy_attachment" "this" {
  user       = var.iam_policy_user_name
  policy_arn = aws_iam_policy.this.arn
}
