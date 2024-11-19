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

data "aws_iam_policy_document" "terraform_create" { # cycle here?
  version = "2012-10-17"

  statement {
    sid    = "General"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "route53:ListHostedZones",
      "acm:ListCertificates",
    ]
    resources = [
      "*"
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
      "acm:DescribeCertificate",
      "acm:GetCertificate"
    ]
    resources = [
      data.aws_acm_certificate.site_cert.arn
    ]
  }

  statement {
    actions = [
      "route53:ListTagsForResource"
    ]
    resources = [
      "arn:aws:route53:::healthcheck/*",
      "arn:aws:route53:::hostedzone/*"
    ]
  }

  statement {
    actions = [
      "acm:ListTagsForCertificate"
    ]
    resources = [
      # "arn:aws:acm:us-east-1:879381244858:certificate/*"
      "arn:aws:acm:${var.region}:${data.aws_caller_identity.current.account_id}:certificate/*"
    ]
  }

  statement {
    sid = "CreateDynamodbTable"
    actions = [
      "dynamodb:CreateTable"
    ]
    resources = [
      "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid = "TerraformLockTableItemAccess"
    actions = [
      "dynamodb:*",
    ]
    resources = [
      "${var.terraform_lock_table_arn}"
    ]
  }

  statement {
    sid = "TerraformLockStateBucketObjectAccess"
    actions = [
      "s3:*"
    ]
    resources = [
      "${var.terraform_s3_state_arn}/*"
    ]
  }

  statement {
    actions = [
      "apigateway:*"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::*"
      #"arn:aws:apigateway:${var.region}::/domainnames",
      #"arn:aws:apigateway:${var.region}::/restapis"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = ["Cloud-Resume-Backend"]
    }
  }

  statement {
    actions = [
      "s3:*"
    ]
    resources = [
      var.terraform_s3_state_arn
      #var.terraform_s3_cloud_resume_pat_state
    ]
  }

  statement {
    actions = [
      "iam:CreateOpenIDConnectProvider"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/*"
    ]
  }

  statement {
    actions = [
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:AttachRolePolicy",
      "iam:TagRole"
    ]
    resources = [
      # was aws_iam_role.github_actions_terraform
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = ["Cloud-Resume-Backend"]
    }
  }

  statement {
    actions = [
      "iam:CreatePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:TagPolicy"
    ]
    resources = [
      aws_iam_policy.github_oidc_safety.arn
      #var.GithubOIDCSafety_policy_arn"aws_iam_policy" "github_oidc_safety"
    ]
  }


  statement {
    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider"
    ]
    resources = [
      data.aws_iam_openid_connect_provider.github.arn
      # aws_iam_openid_connect_provider.github.arn
      #var.OIDC_provider_tokens_actions_githubusercontent "aws_iam_openid_connect_provider" "github"
    ]
  }

  statement {
    actions = [
      "iam:Get*",
      "iam:List*",
      "iam:Create*",
      "iam:Delete*",
      "iam:Update*",
      "iam:Attach*",
      "iam:Tag*",
      "iam:Untag*",
    ]
    resources = [
      "*" # was aws_iam_role.github_actions_terraform 
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = ["Cloud-Resume-Backend"]
    }
  }

  statement {
    actions = [
      "apigateway:GET"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/domainnames/*"
    ]
  }

  statement {
    actions = [
      "apigateway:GET"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/apis/*/integrations/*"
    ]
  }

  statement {
    actions = [
      "apigateway:POST"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/apis/*/deployments"
    ]
  }

  statement {
    actions = [
      "apigateway:GET"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/apis/*/deployments/*"
    ]
  }

  statement {
    actions = [
      "apigateway:POST"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/apis/*/stages"
    ]
  }

  statement {
    actions = [
      "apigateway:GET"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/apis/*/stages"
    ]
  }

  statement {
    actions = [
      "apigateway:POST"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/usageplans"
    ]
  }

  statement {
    actions = [
      "dynamodb:CreateTable",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = ["Cloud-Resume-Backend"]
    }
  }

  # statement {
  #   actions = [
  #     "route53:GetChange"
  #   ]
  #   resources = [
  #     "arn:aws:route53:::change/C06843121UC52O6A6QE4V" # WTF is this?
  #   ]
  # }

  statement {
    actions = [
      "route53:ListResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/*"
    ]
  }

  statement {
    actions = [
      "logs:*"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*:*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = ["Cloud-Resume-Backend"]
    }
  }

  statement {
    actions = [
      "logs:Describe*",
      "logs:List*",
      "logs:Create*",
      "logs:Delete*",
      "logs:Update*",
      "logs:Tag*",
      "logs:Untag*",
    ]
    resources = [
      "*"
    ]
  }

}

resource "aws_iam_policy" "github_actions_terraform" { # cycle here
  name        = "GithubActionsTerraformPermissions_CloudResFront_${var.namespace}"
  description = "Permissions for the Github actions service account for cloud resume challenge"

  policy = data.aws_iam_policy_document.terraform_create.json
}

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
