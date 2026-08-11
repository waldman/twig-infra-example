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
variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_availability_zones" {
  description = "Number of AZs to spread subnets across."
  type        = number
  default     = 2
}

variable "vpc_single_nat_gateway" {
  description = "If true, one NAT for all private subnets (cheap). If false, one per AZ (HA)."
  type        = bool
  default     = true
}
