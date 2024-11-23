output "distribution_arn" {
  value = aws_cloudfront_distribution.cloud_resume_frontend_distribution.arn
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.cloud_resume_frontend_distribution.hosted_zone_id
}

output "domain_name" {
  value = aws_cloudfront_distribution.cloud_resume_frontend_distribution.domain_name
}

output "oac_id" {
  value = aws_cloudfront_origin_access_control.cloudfront_oac.id
}
