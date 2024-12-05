terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.67"
    }
  }
  # s3 backend bootstrap instructions
  # 1. comment out the backend "s3" block
  # 2. apply fresh terraform configuration
  # 3. uncomment backend "s3" block
  # 4. (development) export AWS_PROFILE=***
  # 5. run terraform init
  # s3 backend unboostrap is reverse of above instructions
  # backend "s3" {
  #   bucket         = "cloud-res-front-pat-tf-state"
  #   key            = "global/s3/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "cloud-resume-frontend-terraform-state-lock"
  #   encrypt        = true
  # }

  required_version = ">= 1.9.4"
}

provider "aws" {
  region = "us-east-1"
  # profile = var.aws_profile
  default_tags {
    tags = {
      Project = "Cloud-Resume-Frontend"
    }
  }
}

locals {
  region = "us-east-1"
}

# if this is a testing stage: run the test stage module
# else if this is a prod stage: run the prod stage module

module "test-stage" {
  source = "./terraform/test/"
  region = local.region
}

# module "terraform-state" {
#   source                   = "./terraform/modules/services/terraform-remote-state"
#   s3_state_bucket_name     = "cloud-res-front-pat-tf-state"
#   dynamodb_lock_table_name = "cloud-resume-frontend-terraform-state-lock"
# }
#
# module "route53" {
#   source                                 = "./terraform/modules/services/route53"
#   cloudfront_distribution_domain_name    = module.cloudfront_distribution.domain_name
#   cloudfront_distribution_hosted_zone_id = module.cloudfront_distribution.hosted_zone_id
# }
#
# module "cloudfront_distribution" {
#   source                     = "./terraform/modules/services/cloudfront"
#   website_aliases            = ["resume.patimapoochai.net", "www.patimapoochai.net"]
#   website_bucket_domain_name = module.website_s3_bucket.bucket_domain_name
# }
#
# module "website_s3_bucket" {
#   source                      = "./terraform/modules/services/s3"
#   website_files_path          = "cloud-resume-frontend/out"
#   cloudfront_distribution_arn = module.cloudfront_distribution.distribution_arn
# }
#
# module "github_actions_terraform" {
#   source                      = "./terraform/modules/services/github-actions-permissions"
#   namespace                   = "1"
#   region                      = local.region
#   terraform_lock_table_arn    = module.terraform-state.dynamodb_lock_table_arn
#   terraform_s3_state_arn      = module.terraform-state.state_bucket_arn
#   github_repo_url             = "patimapoochai/cloud-resume-challenge"
#   website_domain_name         = "patimapoochai.net"
#   cloudfront_distribution_arn = module.cloudfront_distribution.distribution_arn
#   distribution_oac_id         = module.cloudfront_distribution.oac_id
#   frontend_website_bucket_arn = module.website_s3_bucket.arn
# }
