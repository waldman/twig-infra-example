variable "profile" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type     = string
  nullable = false
}
