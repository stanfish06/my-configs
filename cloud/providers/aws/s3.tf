resource "aws_iam_role" "this" {
  name_prefix = "cloud-${var.name}-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "this" {
  name_prefix = "cloud-${var.name}-"
  role        = aws_iam_role.this.name
}

data "aws_iam_policy_document" "s3" {
  count = length(var.s3_buckets) > 0 ? 1 : 0

  statement {
    sid       = "ListAll"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }

  statement {
    sid       = "Buckets"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation", "s3:ListBucketMultipartUploads"]
    resources = [for b in var.s3_buckets : "arn:aws:s3:::${b}"]
  }

  statement {
    sid = "Objects"
    actions = concat(
      ["s3:GetObject", "s3:GetObjectTagging"],
      var.s3_write ? [
        "s3:PutObject", "s3:PutObjectTagging", "s3:DeleteObject", "s3:RestoreObject",
        "s3:AbortMultipartUpload", "s3:ListMultipartUploadParts",
      ] : [],
    )
    resources = [for b in var.s3_buckets : "arn:aws:s3:::${b}/*"]
  }
}

resource "aws_iam_role_policy" "s3" {
  count  = length(var.s3_buckets) > 0 ? 1 : 0
  name   = "s3"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.s3[0].json
}
