resource "aws_config_configuration_recorder" "sv_configuration_recorder" {
  role_arn = aws_iam_role.sv_config_iam_role.arn

  recording_group {
    all_supported = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "sv_delivery_channel" {
  s3_bucket_name = aws_s3_bucket.sv_config_log_bucket.id
  depends_on = [ aws_config_configuration_recorder.sv_configuration_recorder ]
}

resource "aws_config_configuration_recorder_status" "sv_configuration_recorder_status" {
  name = aws_config_configuration_recorder.sv_configuration_recorder.name
  is_enabled = true
  depends_on = [ aws_config_delivery_channel.sv_delivery_channel ]
}

resource "aws_iam_role" "sv_config_iam_role" {
  name = "sv-config-iam-role"
  assume_role_policy = jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["config.amazonaws.com"]
      },
      "Effect": "Allow",
    }
  ]
}
)
}

resource "aws_iam_role_policy_attachment" "sv_config_iamrole_policy_attachment0" {
  role = aws_iam_role.sv_config_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_role_policy" "sv_config_inline_iamrole_policy_attachment0" {
  name = "allow-access-to-config-s3-bucket"
  role = aws_iam_role.sv_config_iam_role.id
  policy = jsonencode(
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.config_log_bucket_name}/*"
            ],
            "Condition": {
                "StringLike": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketAcl"
            ],
            "Resource": "arn:aws:s3:::${var.config_log_bucket_name}"
        }
    ]
}
)
}



