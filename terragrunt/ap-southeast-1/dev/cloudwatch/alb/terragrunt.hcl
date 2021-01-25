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

dependency "alb" {
  config_path = "${get_parent_terragrunt_dir()}/ap-southeast-1/dev/alb"
}

dependency "sns" {
  config_path = "${get_parent_terragrunt_dir()}/ap-southeast-1/dev/cloudwatch/sns"
}

inputs = {
  alarm_name          = "alb-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  alarm_description   = "Alarm triggers when CpuUtilization is > 80"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Number of healthy nodes in Target Group"
  actions_enabled     = "true"
  alarm_actions       = ["${dependency.sns.outputs.arn}"]
  dimensions = {
    LoadBalancer = dependency.alb.outputs.this_lb_arn_suffix
    TargetGroup  = element(dependency.alb.outputs.target_group_arn_suffixes, 2)
  }
  tags = {
    Environment = "${local.env}"
    CreatedBy   = "Terraform"
    ManagedBY   = "${local.common_name_prefix}"
  }
}
