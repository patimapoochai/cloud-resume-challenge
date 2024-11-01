terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.67"
    }
  }

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

module "route53" {
  source                                 = "./modules/services/route53"
  cloudfront_distribution_domain_name    = module.cloudfront_distribution.domain_name
  cloudfront_distribution_hosted_zone_id = module.cloudfront_distribution.hosted_zone_id
}

module "cloudfront_distribution" {
  source                     = "./modules/services/cloudfront"
  website_aliases            = ["resume.patimapoochai.net", "www.patimapoochai.net"]
  website_bucket_domain_name = module.website_s3_bucket.bucket_domain_name
}

module "website_s3_bucket" {
  source                      = "./modules/services/s3"
  website_files_path          = "cloud-resume-frontend/out"
  cloudfront_distribution_arn = module.cloudfront_distribution.distribution_arn
}

