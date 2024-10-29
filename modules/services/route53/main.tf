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
