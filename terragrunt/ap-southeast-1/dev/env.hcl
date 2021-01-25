# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  environment        = "dev"
  common_name_prefix = "mastercard"
  #ssh_machine_ip     = "13.234.0.44/32"
  #key_name           = "mastercard"
}