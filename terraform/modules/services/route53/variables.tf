variable "website_aliases" {
  type        = list(string)
  default     = ["resume.patimapoochai.net"]
  description = "URL(s) that resolve to the resume website"
}

variable "domain_name" {
  type        = string
  description = "The fully qualified domain name of the website"
  default     = "patimapoochai.net"
}

variable "cloudfront_distribution_domain_name" {
  type = string
}

variable "cloudfront_distribution_hosted_zone_id" {
  type = string
}
