# Scalable Apache Webserver on AWS

This repository contain the infrastructure as code for highly scalable apache weberever using Terraform + Terragrunt to provision on AWS.

## Requirements

To Design a highly Scalable Webserver which can scale automatically as traffic increase. Which can send alerts when something happen wrong. and  can be managed automatically without human intervention.

## Considerations

1. Traffic is very low at the time of server launch so we will take t2.micro instance type.
2. Backend Server is listening on http
3. SSL Termination happens on ALB
4. ALB logs routed to s3 bucket
5. Self-signed certificate is used 
6. Some of the General Open Source Module is used which is managed and maintained by terraform.
7. I have tested the modules and hcl file on 13.05 version as mine `tgenv` was not working.

## AWS Resource Provision
1. VPC with Flow Logs
2. Subnet
3. Route & Route Table 
4. NAT Gateway & Internet Gateway
5. Elastic IP 
6. Self-Signed Certificate and import to ACM 
7. Application Load Balancer
8. S3 Buckets (Two buckets one for storing alb logs & one to store tfstate file)
9. Security Groups (Two SG one for ASG and one for ALB)
10. CloudWatch Alarm & Alerts

## Configurations

I have used `172.16.0.0/16` VPC CIDR range and break it into 4 subnets 2 private and 2 public So that our Infra can be higly available. 

I have placed my Webserver in private subnet with no Public IP and Placed my Application Load balancer in Public Subnet. Also the traffic at the AlB is encrypted. 

I have only open Port 80 & 443 to listen on ALB and Port 80 on webserver from the VPC CIDR range.

I have generated self-signed certificate and imported to ACM for SSL.

ALL the resources are provision in Singapore region.

Minimum capacity of EC2 is 2 and can scale up to 5.

Configured cloudwatch alarm is for Cpu utilization and unhealthy host of alb. ALB Alarm will sent the alerts to SNS topic. We need to create the subscription for SNS manually as email subscription is not supported by terrafrom.

I have used Terragrunt to spun up the environment So One bucket named `apache-terraform-state`  and dynamodb table name  `apache-terraform-state` will create automatically for storing the tfstate file and for locking the tfstate files.

I have used the open-source General Module which is maintained and manged by Terrafrom isteslf.The modules whiuch were not maintained my terrafrom is not being used Hence the module is written by me only. I have written below modules in the projects.

```
modules
├── acm
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── asg
│   ├── locals.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── cloudwatch
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── scaling-policy
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── sns
│   └── main.tf
├── target-group-attachment
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
└── vpc
    ├── main.tf
    ├── outputs.tf
    └── variables.tf

```

## Directory Structure

```
terragrunt
├── ap-southeast-1
│   ├── dev
│   │   ├── acm
│   │   │   └── terragrunt.hcl
│   │   ├── alb
│   │   │   └── terragrunt.hcl
│   │   ├── asg
│   │   │   ├── data.sh
│   │   │   └── terragrunt.hcl
│   │   ├── cloudwatch
│   │   │   ├── alb
│   │   │   │   └── terragrunt.hcl
│   │   │   ├── asg
│   │   │   │   └── terragrunt.hcl
│   │   │   ├── scaling-policy
│   │   │   │   └── terragrunt.hcl
│   │   │   └── sns
│   │   │       └── terragrunt.hcl
│   │   ├── env.hcl
│   │   ├── s3
│   │   │   └── terragrunt.hcl
│   │   ├── security-group
│   │   │   ├── alb
│   │   │   │   └── terragrunt.hcl
│   │   │   └── asg
│   │   │       └── terragrunt.hcl
│   │   ├── target-group-attachment
│   │   │   └── terragrunt.hcl
│   │   └── vpc
│   │       └── terragrunt.hcl
│   └── region.hcl
└── terragrunt.hcl

```

## Run the Setup

To run the setup you need to install the terragrunt 
    `brew install terragrunt`

1. Clone the repository
2. Navigate to the directory `terragrunt/ap-southeast-1`
3. Create the user on AWS console and download the credentials file 
```
	export AWS_ACCESS_KEY_ID="******************************"
	export AWS_SECRET_ACCESS_KEY=***************************
```
4. Run the below command 

    ```terragrunt apply-all --terragrunt-non-interactive```

## Access the Site

1. Navigate the the dir cd `/terragrunt/ap-southeast-1/dev/alb`
2. Run the Command `terragrunt output`
3. find the dns name of ALB with name `this_lb_dns_name	
4. Hit The URL with https://<this_lb_dns_name> (recommended to use safari browser as we are using self-signed certicicate)
5. OR you can use curl https://<this_lb_dns_name> -k 

## Tools

### Terragrunt

Terragrunt is a thin wrapper that provides extra tools for keeping your configurations DRY, working with multiple Terraform modules, and managing remote state.

#### Benefit of using Terragrunt

Keep your backend configuration DRY
Keep your provider configuration DRY
Keep your Terraform CLI arguments DRY
Promote immutable, versioned Terraform modules across environments

### Pre-commit 

1. Install [pre-commit](http://pre-commit.com/). E.g. `brew install pre-commit`.
2. Run `pre-commit install` in the repo to install hooks.
3. Run `pre-commit run -a` to run checks manually.

### Verions

- terraform v0.13.5
- terragrunt v0.26.7

## Issues

Getting below error while creting the asg alarms The issue is open in github finding the workaround.

```
Error: Creating metric alarm failed: ValidationError: ComparisonOperators for ranges require ThresholdMetricId to be set
	status code: 400, request id: 6b598cdc-2d06-40a4-87b6-20068e98411e
```
## Manual steps

Need to create the SNS subscription manually because currently for email endpoint terraform doesn't support.

Steps to create the Subscription.

1. Go to SNS console select the topis creted by terraform.
2. Click the Subscription button to add it 
3. Add the mail id on which you want to receive the notifications save it and verify the mail id.

## Destroy the Infrastructure 

Use below command to destroy the infra.
```	
	terragrunt destroy-all --terragrunt-non-interactive
```
Once the destroy is completed you need to delete the bucket and table named `mastercard-terraform-state` Manually.
And also need to delete the SNS Subscription which you created manually.`
