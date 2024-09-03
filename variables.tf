variable "bucket-name" {
  type        = string
  description = "The name of the s3 bucket for static website"
  default     = "patima-cloud-resume"
}

variable "website_aliases" {
  type    = list(string)
  default = ["resume.patimapoochai.net"]
}

variable "website_files_path" {
  type        = string
  description = "Relative path to the production build of the static site, no front or ending forward slashes"
  default     = "out"
}

variable "domain_name" {
  type        = string
  description = "The fully qualified domain name of the website"
  default     = "patimapoochai.net"
}
