locals {
  s3_origin_id = "cloud_resume_project_origin"
}

resource "aws_cloudfront_distribution" "cloud_resume_frontend_distribution" {
  enabled = true

  origin {
    domain_name              = var.website_bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id
    origin_id                = local.s3_origin_id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = local.s3_origin_id
    cache_policy_id        = data.aws_cloudfront_cache_policy.Managed_CachingOptimized.id
    compress               = true
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.patimapoochai_net_certificate.arn
    ssl_support_method       = "sni-only" # set this to static-ip for a fun interview story
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  aliases             = concat(var.website_aliases, [var.domain_name])
  default_root_object = "index.html"

}

data "aws_acm_certificate" "patimapoochai_net_certificate" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

data "aws_cloudfront_cache_policy" "Managed_CachingOptimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
  name                              = var.website_bucket_domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


