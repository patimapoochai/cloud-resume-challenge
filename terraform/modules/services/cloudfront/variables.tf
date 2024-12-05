variable "website_bucket_domain_name" {
  type        = string
  description = "Domain name of the frontend bucket"
}

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
