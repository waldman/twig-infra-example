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

variable "sg_vpc_id" {
  description = "VPC in which to create the security group."
  type        = string
}

variable "sg_description" {
  description = "Human-readable description. Defaults to a path-derived string."
  type        = string
  default     = null
}

variable "sg_ingress_rules" {
  description = "List of ingress rules. Each: from_port, to_port, protocol, cidr_blocks."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
