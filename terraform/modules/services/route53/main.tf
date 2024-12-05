data "aws_route53_zone" "patimapoochai_net_zone" {
  name = "${var.domain_name}."
}

resource "aws_route53_record" "non_aliased_records" {
  for_each = toset(var.website_aliases)

  zone_id = data.aws_route53_zone.patimapoochai_net_zone.zone_id
  name    = each.key
  type    = "CNAME"
  ttl     = 300

  records = [var.cloudfront_distribution_domain_name]
}

resource "aws_route53_record" "records" {
  zone_id = data.aws_route53_zone.patimapoochai_net_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    zone_id                = var.cloudfront_distribution_hosted_zone_id
    name                   = var.cloudfront_distribution_domain_name
    evaluate_target_health = false
  }

}
