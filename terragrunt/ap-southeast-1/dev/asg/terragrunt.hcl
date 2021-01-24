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
  source = "${get_parent_terragrunt_dir()}/../modules/asg"
}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "subnet" {
  config_path = "${get_parent_terragrunt_dir()}/ap-southeast-1/dev/vpc"
}

dependency "sg" {
  config_path = "${get_parent_terragrunt_dir()}/ap-southeast-1/dev/security-group/asg"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name = "${local.common_name_prefix}"

  # Launch configuration
  lc_name = "${local.common_name_prefix}-lc"

  image_id                    = "ami-00b8d9cb8a7161e41"
  instance_type               = "t2.micro"
  security_groups             = ["${dependency.sg.outputs.this_security_group_id}"]
  user_data                   = file("${get_parent_terragrunt_dir()}/ap-southeast-1/dev/asg/data.sh")
  key_name                    = "mastercard"
  associate_public_ip_address = false
  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    }
  ]

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    }
  ]

  # Auto scaling group
  asg_name                  = "${local.common_name_prefix}-asg"
  vpc_zone_identifier       = "${dependency.subnet.outputs.private_subnets}"
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "${local.common_name_prefix}"
      propagate_at_launch = true
    },
  ]
  tags_as_map = {
    CreatedBY   = "Terraform"
    ManagedBY   = "${local.common_name_prefix}"
    Environment = "${local.env}"
  }
}