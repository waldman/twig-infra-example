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

variable "ec2_vpc_id" {
  description = "VPC ID (used to scope the security group)."
  type        = string
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

variable "ec2_ssh_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to SSH in. Empty list = no SSH rule."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ec2_extra_ingress_rules" {
  description = "Extra security-group ingress rules. Each: from_port, to_port, protocol, cidr_blocks."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "ec2_user_data" {
  description = "Optional cloud-init / bootstrap script."
  type        = string
  default     = null
}
