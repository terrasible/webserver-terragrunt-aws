variable "domain" {
  type = string
}

variable "organization" {
  type = string
}
variable "validity_period_hours" {
  type    = number
  default = 240
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the Virtual Network resources"
  default     = {}
}