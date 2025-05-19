resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "${var.project}-${var.environment}-bucket-shu"
  force_destroy = true
}
resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.bucket

  versioning_configuration {
    status = "Disabled"
  }
}


resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
    resources = ["${aws_s3_bucket.s3_bucket.arn}/*", "${aws_s3_bucket.s3_bucket.arn}"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ecs_task_role.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
  depends_on = [
    aws_s3_bucket_public_access_block.s3_bucket_public_access_block,
    aws_s3_bucket_versioning.s3_bucket_versioning
  ]   
}