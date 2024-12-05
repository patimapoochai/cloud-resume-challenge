
module "frontend_directory" {
  source   = "hashicorp/dir/template"
  version  = "1.0.2"
  base_dir = "${path.root}/${var.website_files_path}"
}


resource "aws_s3_bucket" "cloud_resume_bucket" {
  bucket = var.bucket_name
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
      values   = [var.cloudfront_distribution_arn]
    }

  }
}
