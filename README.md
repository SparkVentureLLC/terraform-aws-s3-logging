# terraform-aws-s3-logging
The terraform code in this repository allows you to quickly accomplish the task below on your AWS Environment: 

* Create an EC2 Instance (Ubuntu)
* Configure Security Group to controll access to the created EC2 Instance
* Configure Cloudtrail logging to a S3 bucket
* Configure AWS Config to send updated configuration details to S3 Bucket
* Configure VPC Flow logs to be stored on S3 Bucket
* Configure SQS and SNS Topic for VPC FLow log notification that can be used with Splunk

# Requirements
* [Terrafrom][def] - Terraform is an open-source infrastructure as code software tool that provides a consistent CLI workflow to manage hundreds of cloud services. 
* [Amazon AWS Account][def3] and [associated credentials][def4] that allow you to create resources.
* [aws cli][def2]

## Generate an SSH Key Pair (Skip if you already have one)

The teffraform code uses your existing SSH public key when creating the EC2 instance to give you access the machine via SSH.

```
ssh-keygen -b 4096 -t rsa
```
## Overwriting default value
Our terraform code creates firewall rules to allow you to ssh from the specified IP Address to the EC2 instance created. In order to specify our desidred IP Address, A.B.C.D, we will need to create the file **terraform.tfvars** with the content below.

```
cidr_blocks_whitelist_ssh_in = [ "A.B.C.D/32" ]
```

You can also use the same file to overwrite any existing variables defined in **variables.tf**

# Usage
## Inititalize the directory
You will need to first initialize the directory after checking out the code from github.

Initializing a configuration directory downloads and installs the providers defined in the configuration, which in this case is the aws provider.
```
terraform int
```
## Create the infrascture
```
terraform apply
```
Before it applies any changes, Terraform prints out the execution plan which describes the actions Terraform will take in order to change your infrastructure to match the configuration.

# Splunk integration
The blog post [Anlyzing aws vpc flow logs with splunk](https://sparkventure.net/analyzing-aws-vpc-flow-logs-with-splunk/) covers the needed steps o configure your splunk instance to start pulling vpc flow logs stored on a S3 buckets.
> https://sparkventure.net/analyzing-aws-vpc-flow-logs-with-splunk/

Step 1 to 5 is automatically done by the terraform code in this repository. You only need to perform step 6.

[def]: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
[def2]: https://aws.amazon.com/cli/
[def3]: https://aws.amazon.com/it/console/
[def4]: https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html
