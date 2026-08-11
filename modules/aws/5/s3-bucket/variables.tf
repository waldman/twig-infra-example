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

variable "s3_bucket_name" {
  description = "Explicit bucket name. Defaults to <environment>-<class>-<component>-<module>."
  type        = string
  default     = null
}

variable "s3_versioning_enabled" {
  type    = bool
  default = true
}

variable "s3_force_destroy" {
  type    = bool
  default = false
}
