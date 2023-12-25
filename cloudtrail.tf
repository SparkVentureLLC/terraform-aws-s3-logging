data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition

  # Need a list to work with for_each, but don't actually want to for_each
  log_s3     = length(var.cloudtrail_s3_object_level_buckets) > 0 ? [true] : []
  log_lambda = length(var.cloudtrail_lambda_functions) > 0 ? [true] : []
}


# S3 bucket policy for CloudTrail
resource "aws_s3_bucket_policy" "logging_bucket_policy" {
   bucket     = var.cloudtrail_log_bucket_name
  depends_on  = [aws_s3_bucket.sv_cloudtrail_bucket, ]

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AWSCloudTrailAclCheck20231209",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : "s3:GetBucketAcl",
        "Resource" : "arn:aws:s3:::${var.cloudtrail_log_bucket_name}"
      },
      {
        "Sid" : "AWSCloudTrailWrite20231209",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : [
          "arn:aws:s3:::${var.cloudtrail_log_bucket_name}/AWSLogs/${local.account_id}/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}


resource "aws_cloudtrail" "trail" {
  cloud_watch_logs_role_arn  = aws_iam_role.sv_cloudtrail_cloudwatch_events_role.arn
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cwl_loggroup.arn}:*"
  enable_log_file_validation = "true"
  enable_logging             = "true"
  is_multi_region_trail      = "true"
  #kms_key_id                 = var.kms_key_id
  name                       = var.cloudtrail_name
  s3_bucket_name             = var.cloudtrail_log_bucket_name
  tags                       = var.cloudtrail_tags

  # S3 object logging:
  event_selector {
    read_write_type           = "All"
    include_management_events = true

    dynamic "data_resource" {
      for_each = local.log_s3
      content {
        type   = "AWS::S3::Object"
        values = var.cloudtrail_s3_object_level_buckets
      }
    }

    dynamic "data_resource" {
      for_each = local.log_lambda
      content {
        type   = "AWS::Lambda::Function"
        values = var.cloudtrail_lambda_functions
      }
    }
  }
}

resource "aws_iam_role" "sv_cloudtrail_cloudwatch_events_role" {
  name_prefix        = "cloudtrail_events_role"
  path               = var.cloudtrail_iam_path
  assume_role_policy = data.aws_iam_policy_document.cwl_assume_policy.json
  tags               = var.cloudtrail_tags
}

resource "aws_iam_role_policy" "cwl_policy" {
  name_prefix = "cloudtrail_cloudwatch_events_policy"
  role        = aws_iam_role.sv_cloudtrail_cloudwatch_events_role.id
  policy      = data.aws_iam_policy_document.cwl_policy.json
}

data "aws_iam_policy_document" "cwl_assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cwl_policy" {
  statement {
    effect  = "Allow"
    actions = ["logs:CreateLogStream"]


    resources = [
      "arn:${local.partition}:logs:${var.region}:${local.account_id}:log-group:${aws_cloudwatch_log_group.cwl_loggroup.name}:log-stream:*",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["logs:PutLogEvents"]

    resources = [
      "arn:${local.partition}:logs:${var.region}:${local.account_id}:log-group:${aws_cloudwatch_log_group.cwl_loggroup.name}:log-stream:*",
    ]
  }
}

resource "aws_cloudwatch_log_group" "cwl_loggroup" {
  name              = var.cloudtrail_log_group_name
  #kms_key_id        = var.kms_key_id
  retention_in_days = var.cloudtrail_retention_in_days == -1 ? null : var.cloudtrail_retention_in_days
  tags              = var.cloudtrail_tags
}

resource "aws_cloudwatch_log_stream" "cwl_stream" {
  name           = local.account_id
  log_group_name = aws_cloudwatch_log_group.cwl_loggroup.name
}