# Scalable Apache Webserver on AWS

This repository contain the infrastructure as code for highly scalable apache weberever using Terraform + Terragrunt to provision on AWS.



### Setup and usage

1. Install [pre-commit](http://pre-commit.com/). E.g. `brew install pre-commit`.
2. Run `pre-commit install` in the repo to install hooks.
3. Run `pre-commit run -a` to run checks manually.

### Tools

Here are the specific version of tools to be used during the development of the infrastructure. To better manage `terraform` and `terragrunt` may opt to use [tfenv](https://github.com/tfutils/tfenv) and [tgenv](https://github.com/alextodicescu/homebrew-tgenv) respectively.

- terraform v0.13.5
- terragrunt v0.26.7
