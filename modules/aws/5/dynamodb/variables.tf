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

variable "dynamodb_table_name" {
  description = "Explicit table name. Defaults to <environment>-<class>-<component>-<module>."
  type        = string
  default     = null
}

variable "dynamodb_hash_key" {
  description = "Partition key attribute name."
  type        = string
}

variable "dynamodb_hash_key_type" {
  description = "Partition key attribute type (S, N, or B)."
  type        = string
  default     = "S"
}

variable "dynamodb_billing_mode" {
  description = "PAY_PER_REQUEST or PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_ttl_enabled" {
  description = "Enable TTL on the table."
  type        = bool
  default     = false
}

variable "dynamodb_ttl_attribute" {
  description = "Attribute name used for TTL (required when dynamodb_ttl_enabled = true)."
  type        = string
  default     = ""
}
