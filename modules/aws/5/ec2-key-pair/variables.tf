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

# Module-specific — prefixed with module name (ec2-key-pair → ec2_key_pair_).
variable "ec2_key_pair_public_key" {
  description = "OpenSSH-format public key content (e.g. 'ssh-ed25519 AAAA... comment')."
  type        = string
}
