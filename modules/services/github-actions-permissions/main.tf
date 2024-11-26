locals {
  github_oidc_url = "token.actions.githubusercontent.com"
}

data "aws_route53_zone" "patimapoochai_net_zone" {
  name = "${var.website_domain_name}."
}

data "aws_acm_certificate" "site_cert" {
  domain   = var.website_domain_name
  statuses = ["ISSUED"]
}

data "aws_caller_identity" "current" {}

data "aws_cloudfront_cache_policy" "cachingoptimized" {
  name = "Managed-CachingOptimized"
}

data "aws_iam_policy_document" "terraform_create" { # cycle here?
  version = "2012-10-17"

  statement {
    sid    = "General"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "route53:ListHostedZones",
      "cloudfront:ListCachePolicies",
      "acm:ListCertificates",
      "iam:ListOpenIDConnectProviders",
      "cloudfront:CreateOriginAccessControl",
      "cloudfront:CreateDistributionWithTags"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "s3:Get*",
      "s3:Put*",
      "s3:ListBucket",
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:CreateBucket"
    ]
    resources = [
      var.terraform_s3_state_arn,
      var.frontend_website_bucket_arn
    ]
  }

  statement {
    actions = [
      "s3:Get*",
      "s3:Put*",
      "s3:DeleteObject",
      "s3:HeadObject"
    ]
    resources = [
      "${var.terraform_s3_state_arn}/*",
      "${var.frontend_website_bucket_arn}/*",
      "${var.frontend_website_bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:List*",
      "dynamodb:Tag*",
      "dynamodb:Describe*"
    ]
    resources = [
      var.terraform_lock_table_arn
    ]
  }

  statement {
    actions = [
      "route53:GetHostedZone"
    ]
    resources = [
      data.aws_route53_zone.patimapoochai_net_zone.arn
    ]
  }

  statement {
    actions = [
      "iam:GetPolicy*",
      "iam:ListPolicy*",
      "iam:DeletePolicy",
      "iam:CreatePolicy"
    ]
    resources = [
      aws_iam_policy.github_oidc_safety.arn,
      # aws_iam_policy.github_actions_terraform.arn # this will cause a cycle
    ]
  }

  statement {
    actions = [
      "acm:DescribeCertificate",
      "acm:GetCertificate"
    ]
    resources = [
      data.aws_acm_certificate.site_cert.arn
    ]
  }

  statement {
    actions = [
      "route53:ListTagsForResource",
      "route53:ListResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::healthcheck/*",
      "arn:aws:route53:::hostedzone/*"
    ]
  }

  statement {
    actions = [
      "cloudfront:GetCachePolicy"
    ]
    resources = [
      "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:cache-policy/${data.aws_cloudfront_cache_policy.cachingoptimized.id}"
    ]
  }

  statement {
    actions = [
      "iam:GetOpenIDConnectProvider"
    ]
    resources = [
      data.aws_iam_openid_connect_provider.github.arn
    ]
  }

  statement {
    actions = [
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:DetachRolePolicy",
      "iam:ListInstanceProfilesForRole",
      "iam:DeleteRole",
      "iam:CreateRole",
      "iam:AttachRolePolicy"
    ]
    resources = [
      aws_iam_role.github_actions_terraform.arn
    ]
  }

  statement {
    actions = [
      "acm:ListTagsForCertificate"
    ]
    resources = [
      "arn:aws:acm:us-east-1:${data.aws_caller_identity.current.account_id}:certificate/*"
    ]
  }


  statement {
    actions = [
      "cloudfront:GetOriginAccessControl",
      "cloudfront:DeleteOriginAccessControl"
    ]
    resources = [
      "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:origin-access-control/${var.distribution_oac_id}",
      "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:origin-access-control/E1QXFM0PHHS1LU", // what is this?
      "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:origin-access-control/E3N39S793IBFH"
    ]
  }

  statement {
    actions = [
      "cloudfront:GetDistribution",
      "cloudfront:ListTagsForResource",
      "cloudfront:UpdateDistribution",
      "cloudfront:DeleteDistribution"
    ]
    resources = [
      var.cloudfront_distribution_arn,
      "arn:aws:cloudfront::879381244858:distribution/EVPIUBUX170DL"
    ]
  }

  statement {
    actions = [
      "route53:GetChange"
    ]
    resources = [
      "arn:aws:route53:::change/C096490527OIHEQI3FW3D",
      "arn:aws:route53:::change/C06167491TJ2EX1S6LLSC",
      "arn:aws:route53:::change/C10286161LEOXNJ027SS9",
      "arn:aws:route53:::change/C05634672BL8A5CZWYXHF" // what are these?
    ]
  }

}

resource "aws_iam_policy" "github_actions_terraform" { # cycle here
  name        = "GithubActionsTerraformPermissions_CloudResFront_${var.namespace}"
  description = "Permissions for the Github actions service account for cloud resume challenge"

  policy = data.aws_iam_policy_document.terraform_create.json
}

# Already provided?
# resource "aws_iam_openid_connect_provider" "github" {
#   url = "https://${local.github_oidc_url}"
#   client_id_list = [
#     "sts.amazonaws.com"
#   ]
#   thumbprint_list = [
#     "d89e3bd43d5d909b47a18977aa9d5ce36cee184c"
#   ]
# }

data "aws_iam_openid_connect_provider" "github" {
  url = "https://${local.github_oidc_url}"
}

data "aws_iam_policy_document" "oidc_safety" {
  version = "2012-10-17"
  statement {
    sid    = "OidcSafeties"
    effect = "Deny"
    actions = [
      "sts:AssumeRole",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "github_oidc_safety" {
  name        = "GithubOIDCSafety_CloudResFront_${var.namespace}"
  description = "Deny service accounts from assuming another role in cloud resume challenge"

  policy = data.aws_iam_policy_document.oidc_safety.json
}

data "aws_iam_policy_document" "github_actions_oidc_access" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.github_oidc_url}"
      ]
    }
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo_url}:ref:refs/heads/main"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "github_actions_terraform" {
  name               = "GithubActions_CloudResFront_${var.namespace}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_oidc_access.json
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform_oidc" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = aws_iam_policy.github_oidc_safety.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform_deployment" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = aws_iam_policy.github_actions_terraform.arn
}
