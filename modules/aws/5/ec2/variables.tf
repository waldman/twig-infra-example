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

# Module-specific — prefixed with module name.
variable "ec2_ami" {
  description = "AMI ID."
  type        = string
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.small"
}

variable "ec2_subnet_id" {
  description = "Subnet in which to launch the instance."
  type        = string
}

variable "ec2_security_group_ids" {
  description = "Security group IDs to attach to the instance."
  type        = list(string)
}

variable "ec2_key_name" {
  description = "Name of an existing aws_key_pair. Null = no key associated."
  type        = string
  default     = null
}

variable "ec2_associate_public_ip" {
  type    = bool
  default = true
}

variable "ec2_root_volume_size_gb" {
  type    = number
  default = 20
}

variable "ec2_user_data" {
  description = "Optional cloud-init / bootstrap script."
  type        = string
  default     = null
}
