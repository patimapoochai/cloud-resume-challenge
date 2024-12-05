# test environment

module "terraform-state" {
  source                   = "../modules/services/terraform-remote-state"
  s3_state_bucket_name     = "cloud-res-front-pat-tf-state"
  dynamodb_lock_table_name = "cloud-resume-frontend-terraform-state-lock"
}

module "route53" {
  source                                 = "../modules/services/route53"
  cloudfront_distribution_domain_name    = module.cloudfront_distribution.domain_name
  cloudfront_distribution_hosted_zone_id = module.cloudfront_distribution.hosted_zone_id
}

module "cloudfront_distribution" {
  source                     = "../modules/services/cloudfront"
  website_aliases            = ["resume.patimapoochai.net", "www.patimapoochai.net"]
  website_bucket_domain_name = module.website_s3_bucket.bucket_domain_name
}

module "website_s3_bucket" {
  source                      = "../modules/services/s3"
  website_files_path          = "cloud-resume-frontend/out"
  cloudfront_distribution_arn = module.cloudfront_distribution.distribution_arn
}

module "github_actions_terraform" {
  source                      = "../modules/services/github-actions-permissions"
  namespace                   = "1"
  region                      = var.region
  terraform_lock_table_arn    = module.terraform-state.dynamodb_lock_table_arn
  terraform_s3_state_arn      = module.terraform-state.state_bucket_arn
  github_repo_url             = "patimapoochai/cloud-resume-challenge"
  website_domain_name         = "patimapoochai.net"
  cloudfront_distribution_arn = module.cloudfront_distribution.distribution_arn
  distribution_oac_id         = module.cloudfront_distribution.oac_id
  frontend_website_bucket_arn = module.website_s3_bucket.arn
}
