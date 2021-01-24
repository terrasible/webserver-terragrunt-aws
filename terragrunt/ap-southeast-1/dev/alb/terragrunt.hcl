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
  source = "git@github.com:terraform-aws-modules/terraform-aws-alb.git//?ref=master"
}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "${get_parent_terragrunt_dir()}/ap-southeast-1/dev/vpc"
}

dependency "sg" {
  config_path = "${get_parent_terragrunt_dir()}/ap-southeast-1/dev/security-group/alb"
}

dependency "s3" {
  config_path = "${get_parent_terragrunt_dir()}/ap-southeast-1/dev/s3"
}

dependency "acm" {
  config_path = "${get_parent_terragrunt_dir()}/ap-southeast-1/dev/acm"
}
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name = "${local.common_name_prefix}-alb"

  load_balancer_type = "application"

  vpc_id  = "${dependency.vpc.outputs.vpc_id}"
  subnets = "${dependency.vpc.outputs.public_subnets}"

  security_groups = ["${dependency.sg.outputs.this_security_group_id}"]

  enable_deletion_protection = false

  access_logs = {
    bucket = "${dependency.s3.outputs.this_s3_bucket_id}"
    prefix = "${local.common_name_prefix}-log"
  }
  target_groups = [
    {
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        protocol            = "HTTP"
        path                = "/"
        interval            = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 2
        matcher             = "200-299"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "${dependency.acm.outputs.arn}"
      target_group_index = 0
    },
  ]
  tags = {
    Environment = "${local.env}"
    CreatedBy   = "Terraform"
    ManagedBY   = "${local.common_name_prefix}"
  }
}