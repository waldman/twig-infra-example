output "user_name" {
  value = aws_iam_user.this.name
}

output "user_arn" {
  value = aws_iam_user.this.arn
}

output "access_key_id" {
  value     = try(aws_iam_access_key.this[0].id, null)
  sensitive = true
}

output "secret_access_key" {
  value     = try(aws_iam_access_key.this[0].secret, null)
  sensitive = true
}

output "secrets_manager_arn" {
  description = "ARN of the Secrets Manager secret holding {access_key_id, secret_access_key}. Null if SM write was skipped."
  value       = try(aws_secretsmanager_secret.credentials[0].arn, null)
}

output "secrets_manager_name" {
  description = "Name of the Secrets Manager secret. Null if SM write was skipped."
  value       = try(aws_secretsmanager_secret.credentials[0].name, null)
}
