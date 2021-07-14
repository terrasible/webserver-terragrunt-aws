module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"
  name = "codepipe-test-vpc"
  cidr = "172.16.0.0/16"

  # The zones we will be using will only be ap-southeast-1a, ap-southeast-1b
  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["172.16.1.0/24", "172.16.2.0/24"]

  public_subnets = ["172.16.101.0/24", "172.16.102.0/24"]

  # enable nat & mappping of Public IP
  map_public_ip_on_launch              = true
  enable_nat_gateway                   = true
  single_nat_gateway                   = true
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = {
    Environment = "dev"
    CreatedBY   = "Terraform"
    ManagedBY   = "codepipe-test"
  }
}
module "ec2" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git"
  name = "codepipe-test"

  ami                         = "ami-02f26adf094f51167"
  instance_count              = 1
  instance_type               = "t2.micro"
  subnet_ids                  = module.vpc.public_subnets
  associate_public_ip_address = true
  key_name                    = "dev"
  monitoring                  = true
  user_data                   = file("./data.sh")
  vpc_security_group_ids = [
    module.sg.security_group_id
  ]
  tags = {
    Environment = "dev"
    CreatedBy   = "Terraform"
    ManagedBy   = "codepipe-test"
  }
}

module "sg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git"
  name   = "codepipe-asg-sg"
  vpc_id = module.vpc.vpc_id

  # Allow OpenVPN client CIDR
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "ssh to server from local PC"
    }
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = {
    ManagedBy   = "codepipe"
    CreatedBY   = "Terraform"
    Environment = "dev"
  } 
}  