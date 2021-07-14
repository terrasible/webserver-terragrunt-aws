variable "vpc_name" {
  description = "the cidr block for the vpc."
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "vpc cidr value "
  default     = ""
}
variable "public_subnets" {
  description = "list of public subnets"
  type        = list(any)
  default     = []
}
variable "private_subnets" {
  description = "list of Private subnets"
  type        = list(any)
  default     = []
}
variable "tenancy" {
  description = "a tenancy option for instances launched into the vpc"
  type        = string
  default     = "default"
}
variable "dns_hostnames" {
  description = "should be true to enable DNS hostnames in the vpc"
  type        = bool
  default     = false
}
variable "classic_link" {
  description = "should be true to enable classicLink for the vpc. Only valid in regions and accounts that support EC2 classic."
  type        = bool
  default     = false
}
variable "dns_support" {
  description = "should be true to enable dns support in the vpc"
  type        = bool
  default     = true
}
variable "enable_classiclink_dns_support" {
  description = "should be true to enable classicLink dns support for the vpc. Only valid in regions and accounts that support ec2 Classic."
  type        = bool
  default     = false
}
variable "enable_ipv6" {
  description = "requests an amazon-provided IPv6 cidr block with a /56 prefix length for the vpc. You cannot specify the range of IP addresses, or the size of the cidr block."
  type        = bool
  default     = false
}
variable "tags" {
  type    = map(any)
  default = {}
}
variable "create_ig" {
  description = "controls if user wants to create internet gateway set true if we need to create"
  type        = bool
  default     = true

}
variable "map_public_ip_on_launch" {
  description = "specify true to indicate that instances launched into the subnet should be assigned a public IP address."
  type        = bool
  default     = "false"
}
variable "create_eip" {
  description = "set true if we want to create it"
  type        = bool

}
variable "create_nat_gateway" {
  description = "set true if we want to create it"
  type        = bool

}
variable "destination_cidr_block" {
  default = "0.0.0.0/0"
}
variable "create_public_route" {
  description = "set if you want to create the external route"
  type        = bool

}
variable "manage_default_security_group" {
  description = "Should be true to adopt and manage default security group"
  type        = bool
  default     = false
}

variable "default_security_group_ingress" {
  description = "List of maps of ingress rules to set on the default security group"
  type        = list(map(string))
  default     = null
}
variable "default_security_group_egress" {
  description = "List of maps of egress rules to set on the default security group"
  type        = list(map(string))
  default     = null
}