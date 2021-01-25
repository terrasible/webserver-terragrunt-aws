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
  source = "${get_parent_terragrunt_dir()}/../modules/scaling-policy"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "asg" {
  config_path = "${get_parent_terragrunt_dir()}/ap-southeast-1/dev/asg"
}

inputs = {
  name                   = "alb-scaling-policy"
  autoscaling_group_name = "${dependency.asg.outputs.autoscaling_group_name[0]}"

  tags = {
    Environment = "${local.env}"
    CreatedBy   = "Terraform"
    ManagedBY   = "${local.common_name_prefix}"
  }
}