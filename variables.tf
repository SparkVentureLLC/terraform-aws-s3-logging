variable "ami" {
   type        = string
   description = "Ubuntu 22 LTS AMI ID"
   default     = "ami-0fc5d935ebf8bc3bc"
}

variable "instance_type" {
   type        = string
   description = "Instance type"
   default     = "t2.micro"
}

variable "ec2_name" {
   type        = string
   description = "Name of the EC2 instance"
   default     = "EC2 Instance"
}

variable "cidr_blocks_whitelist_ssh_in" {
  type        = list(string)
  description = "List of IPs allowed to SSH in"
  default     = []
}

variable "vpc" {
  type    = string
  default = "default"
  
}

variable "key_name" {
  type        = string
  default     = "access-ssh-key"
  description = "SSH key name"
}

variable "ssh_public_key_file" {
  type = string
  default = "~/.ssh/id_rsa.pub"
  description = "My ssh public key file"
}

# S3 bucket name
variable "config_log_bucket_name" {
  type    = string
  default = "sv-config-log-bucket"
}

variable "flow_log_bucket_name" {
  type    = string
  default = "sv-flow-log-bucket"
}

variable "region" { 
  default = "us-east-1" 
  type    = string
}

variable "cloudtrail_name" {
  default     = "sv-cloudtrail"
  description = "Name for the CloudTrail"
  type        = string
}

variable "cloudtrail_log_bucket_name" {
  type        = string
  default     = "sv-cloudtrail-log-bucket"
  description = "Cloudtrail bucket name"
}

variable "cloudtrail_lambda_functions" {
  default     = []
  description = "Lambda functions to log. Specify `[\"arn:aws:lambda\"]` for all, or `[ ]` for none."
  type        = list
}

variable "cloudtrail_s3_object_level_buckets" {
  default     = []
  description = "ARNs of buckets for which to enable object level logging. Specify `[\"arn:aws:s3:::\"]` for all, or `[ ]` for none. If listing ARNs, make sure to end each one with a `/`."
  type        = list
}

variable "cloudtrail_retention_in_days" {
  default     = 7
  description = "How long should CloudTrail logs be retained in CloudWatch (does not affect S3 storage). Set to -1 for indefinite storage."
  type        = number
}

variable "cloudtrail_iam_path" {
  default     = "/"
  description = "Path under which to put the IAM role. Should begin and end with a '/'."
  type        = string
}


variable "cloudtrail_tags" {
  default     = {}
  description = "Mapping of any extra tags you want added to resources"
  type        = map(string)
}

variable "cloudtrail_log_group_name" {
  default     = "sv-cloudtrail-log-group"
  description = "Name for CloudTrail log group"
  type        = string
}

variable "sqs_vpc_flow_name" {
  default     =  "sv-sqs-vps-flow-log"
  description =  "Name for the SQS"
  type        = string
}

variable "sqs_vpc_flow_dead_letter_name" {
  default     =  "sv-sqs-vpc-flow-log-dead-letter"
  description =  "Name for the SQS"
  type        = string
}


variable "sns_topic_name" {
  default     = "sv-sns-topic-vpcflow"
  description = "Name of the SNS Topic"
  type        = string
}