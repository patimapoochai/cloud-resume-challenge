variable "website_files_path" {
  type        = string
  description = "Absolute path from root to the production build of the static site, no front or ending forward slashes"
}

variable "bucket_name" {
  type        = string
  description = "The name of the s3 bucket for static website"
  default     = "patima-cloud-resume"
}

variable "cloudfront_distribution_arn" {
  type        = string
  description = "ARN of the cloudfront distribution for the frontend"
}
