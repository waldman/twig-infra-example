locals {
  user_name            = "${var.environment}-${var.class}-${var.component}-${var.module}"
  secrets_manager_name = var.secrets_manager_name != null ? var.secrets_manager_name : "terraform/${var.cloud}/${var.profile}/${var.region}/${var.environment}/${var.class}/${var.component}/${var.module}"
  write_secret         = var.iam_user_create_access_key
}

resource "aws_iam_user" "this" {
  name = local.user_name
  tags = var.default_tags
}

resource "aws_iam_user_policy_attachment" "managed" {
  count      = length(var.iam_user_attach_policy_arns)
  user       = aws_iam_user.this.name
  policy_arn = var.iam_user_attach_policy_arns[count.index]
}

resource "aws_iam_user_policy" "inline" {
  count  = var.iam_user_inline_policy_json == null ? 0 : 1
  name   = "${local.user_name}-inline"
  user   = aws_iam_user.this.name
  policy = var.iam_user_inline_policy_json
}

resource "aws_iam_access_key" "this" {
  count = var.iam_user_create_access_key ? 1 : 0
  user  = aws_iam_user.this.name
}

# ---------------------------------------------------------------------------
# Durable credential storage — writes the {access_key_id, secret_access_key}
# pair to AWS Secrets Manager. Standard pattern across credential-producing
# modules; see CLAUDE.md.
# ---------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "credentials" {
  count       = local.write_secret ? 1 : 0
  name        = local.secrets_manager_name
  description = "IAM user credentials for ${local.user_name} (managed by terraform)"
  tags        = var.default_tags
}

resource "aws_secretsmanager_secret_version" "credentials" {
  count     = local.write_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.credentials[0].id
  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.this[0].id
    secret_access_key = aws_iam_access_key.this[0].secret
  })
}
