variable "namespace" {
  description = "Namespace string added at the end of resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "website_domain_name" {
  description = "Domain name of the website e.g. patimapoochai.net"
  type        = string
}

variable "terraform_lock_table_arn" {
  type = string
}

variable "terraform_s3_state_arn" {
  type = string
}

variable "github_repo_url" {
  type        = string
  description = "ACCOUNT/REPO_NAME, use as repo:ACCOUNT/REPO_NAME:ref:refs/heads/main"
}

variable "frontend_website_bucket_arn" {
  type        = string
  description = "ARN of cloud resume site ucket"
}

variable "distribution_oac_id" {
  type        = string
  description = "distribution id"
}

variable "cloudfront_distribution_arn" {
  type        = string
  description = "ARN of cloudfront distribution"
}
