locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  env                = local.environment_vars.locals.environment
  region             = local.region_vars.locals.region
  zones              = local.region_vars.locals.zones
  common_name_prefix = local.environment_vars.locals.common_name_prefix
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-security-group.git//?ref=v3.17.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "${get_parent_terragrunt_dir()}/ap-southeast-1/dev/vpc/"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name   = "${local.common_name_prefix}-alb-sg"
  vpc_id = "${dependency.vpc.outputs.vpc_id}"

  # Allow OpenVPN client CIDR
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]

  tags = {
    ManagedBY   = "${local.common_name_prefix}"
    CreatedBY   = "Terraform"
    Environment = "${local.env}"
  }
}