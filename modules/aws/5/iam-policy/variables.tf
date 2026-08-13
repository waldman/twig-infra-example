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

variable "iam_policy_statements" {
  description = "List of IAM policy statement objects."
  type = list(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
}
