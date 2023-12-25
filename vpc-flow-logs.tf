#Cloud watch location
resource "aws_flow_log" "sv_flow_log_cloudwatch" {
  iam_role_arn    = aws_iam_role.sv_iam_role.arn
  log_destination = aws_cloudwatch_log_group.sv_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_default_vpc.default.id
}

resource "aws_cloudwatch_log_group" "sv_log_group" {
  name = "sv_log_group"
}

data "aws_iam_policy_document" "sv_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "sv_iam_role" {
  name               = "sv_iam_role"
  assume_role_policy = data.aws_iam_policy_document.sv_assume_role.json
}

data "aws_iam_policy_document" "sv_iam_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "sv_iam_role_policy" {
  name   = "sv_iam_role_policy"
  role   = aws_iam_role.sv_iam_role.id
  policy = data.aws_iam_policy_document.sv_iam_policy_document.json
}


##################
# S3 Logs
##################
resource "aws_flow_log" "sv_flow_log_s3" {
  log_destination      = aws_s3_bucket.sv_flow_log_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_default_vpc.default.id
}

