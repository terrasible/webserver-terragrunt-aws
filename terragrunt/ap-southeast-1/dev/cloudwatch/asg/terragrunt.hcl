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
  source = "${get_parent_terragrunt_dir()}/../modules/cloudwatch"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  alarm_name          = "webserver-cpu-alarm"
  comparison_operator = "GreaterThanUpperThreshold"
  alarm_description   = "Alarm triggers when CpuUtilization is > 80"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"
  dimensions = {
    "AutoScalingGroupName" = "mastercard",
  }
  tags = {
    Environment = "${local.env}"
    CreatedBy   = "Terraform"
    ManagedBY   = "${local.common_name_prefix}"
  }
}
