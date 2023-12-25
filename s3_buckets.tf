resource "aws_s3_bucket" "sv_flow_log_bucket" {
  bucket        = var.flow_log_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "sv_config_log_bucket" {
  bucket        = var.config_log_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "sv_cloudtrail_bucket" {
  bucket        = var.cloudtrail_log_bucket_name
  force_destroy = true
}