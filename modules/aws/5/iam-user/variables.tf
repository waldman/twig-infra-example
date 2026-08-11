variable "cloud"       { type = string }
variable "profile"     { type = string }
variable "region"      { type = string }
variable "environment" { type = string }
variable "class"       { type = string }
variable "component"   { type = string }
variable "module"      { type = string }

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "secrets_manager_name" {
  type    = string
  default = null
}

# Module-specific — prefixed with module name (iam-user → iam_user_).
variable "iam_user_attach_policy_arns" {
  description = "List of managed-policy ARNs (AWS-managed or customer-managed) to attach."
  type        = list(string)
  default     = []
}

variable "iam_user_inline_policy_json" {
  description = "Optional inline policy document (JSON string). Null = no inline policy."
  type        = string
  default     = null
}

variable "iam_user_create_access_key" {
  description = "Whether to create an access key/secret pair. Marked sensitive on output."
  type        = bool
  default     = true
}
