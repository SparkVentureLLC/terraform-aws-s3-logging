

# Dead letter
resource "aws_sqs_queue" "sv_sqs_deadletter_queue" {
  name                  = var.sqs_vpc_flow_dead_letter_name
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled = true
}



resource "aws_sqs_queue" "sv_sqs_vpc_flow_log" {
  name                       = var.sqs_vpc_flow_name
  delay_seconds              = 10
  visibility_timeout_seconds = 300
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sv_sqs_deadletter_queue.arn,
    maxReceiveCount     = 10
  })
}


data "aws_iam_policy_document" "sv_iam_sqs_dlq_policy" {
  statement {
    sid    = "__owner_statement"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "sqs:*"
    ]
    resources = [
      aws_sqs_queue.sv_sqs_deadletter_queue.arn
    ]

  }
}

resource "aws_sqs_queue_policy" "sv_sqs_dlq_policy" {
  queue_url = aws_sqs_queue.sv_sqs_deadletter_queue.id
  policy    = data.aws_iam_policy_document.sv_iam_sqs_dlq_policy.json
}




data "aws_iam_policy_document" "sv_iam_sqs_policy" {
  statement {
    sid    = "__owner_statement"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "sqs:*"
    ]
    resources = [
      aws_sqs_queue.sv_sqs_vpc_flow_log.arn
    ]

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:SourceAccount"
      values   = ["${local.account_id}"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.sv_flow_log_bucket.arn]

    }


  }
}

resource "aws_sqs_queue_policy" "sv_sqs_queue_policy" {
  queue_url = aws_sqs_queue.sv_sqs_vpc_flow_log.id
  policy    = data.aws_iam_policy_document.sv_iam_sqs_policy.json
}


data "aws_iam_policy_document" "sv_sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    sid     = "__default_statement_ID"
    effect  = "Allow"

    actions = [
      "SNS:Publish"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [
        local.account_id,
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values = [
        aws_s3_bucket.sv_flow_log_bucket.arn,
      ]
    }


    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:sns:${var.region}:${local.account_id}:${var.sns_topic_name}",
    ]

  }

}

resource "aws_sns_topic" "sv_sns_topic" {
  name = var.sns_topic_name
  policy = data.aws_iam_policy_document.sv_sns_topic_policy.json
}

resource "aws_sns_topic_subscription" "sv_topic_subsciption" {
    topic_arn = "${aws_sns_topic.sv_sns_topic.arn}"
    protocol  = "sqs"
    endpoint  = "${aws_sqs_queue.sv_sqs_vpc_flow_log.arn}"
}


resource "aws_s3_bucket_notification" "sv_bucket_notification" {
  bucket = aws_s3_bucket.sv_flow_log_bucket.id

  topic {
    topic_arn     = aws_sns_topic.sv_sns_topic.arn
    events        = ["s3:ObjectCreated:*"]
    #filter_suffix = ".log"
  }
}