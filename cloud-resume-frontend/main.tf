locals {
  s3_origin_id = "cloud_resume_project_origin"
}

module "frontend_directory" {
  source   = "hashicorp/dir/template"
  version  = "1.0.2"
  base_dir = "${path.module}/${var.website_files_path}"
}


resource "aws_s3_bucket" "cloud_resume_bucket" {
  bucket = var.bucket-name
}

resource "aws_s3_object" "frontend_files" {
  # from https://stackoverflow.com/questions/57456167/uploading-multiple-files-in-aws-s3-from-terraform
  for_each     = module.frontend_directory.files
  bucket       = aws_s3_bucket.cloud_resume_bucket.bucket
  key          = each.key
  source       = each.value.source_path
  content_type = each.value.content_type
}

resource "aws_s3_bucket_policy" "cloudfront_access_only" {
  bucket = aws_s3_bucket.cloud_resume_bucket.id
  policy = data.aws_iam_policy_document.cloud_resume_bucket_policy.json
}

data "aws_iam_policy_document" "cloud_resume_bucket_policy" {
  version   = "2008-10-17"
  policy_id = "PolicyForCloudFrontPrivateContent"

  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.cloud_resume_bucket.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.cloud_resume_frontend_distribution.arn]
    }

  }
}

resource "aws_cloudfront_distribution" "cloud_resume_frontend_distribution" {
  enabled = true

  origin {
    domain_name              = aws_s3_bucket.cloud_resume_bucket.bucket_domain_name
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
  name                              = aws_s3_bucket.cloud_resume_bucket.bucket_domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_route53_zone" "patimapoochai_net_zone" {
  name = "${var.domain_name}."
}

resource "aws_route53_record" "non_aliased_records" {
  for_each = toset(var.website_aliases)

  zone_id = data.aws_route53_zone.patimapoochai_net_zone.zone_id
  name    = each.key
  type    = "CNAME"
  ttl     = 300

  records = [aws_cloudfront_distribution.cloud_resume_frontend_distribution.domain_name]
}

resource "aws_route53_record" "records" {
  zone_id = data.aws_route53_zone.patimapoochai_net_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    zone_id                = aws_cloudfront_distribution.cloud_resume_frontend_distribution.hosted_zone_id
    name                   = aws_cloudfront_distribution.cloud_resume_frontend_distribution.domain_name
    evaluate_target_health = false
  }

}
