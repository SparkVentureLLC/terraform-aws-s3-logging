resource "aws_default_vpc" "default" {
    tags = {
        Name = "Default VPC"
    }
}


########################
# Main Security Group
########################

resource "aws_security_group" "sg_sparkmain" {
  description            = "Main Security Group"
  revoke_rules_on_delete = true
  vpc_id                 = aws_default_vpc.default.id
  #tags                   = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

##########################################
# security group rules for access
#########################################

# SSH access in from whitelist IP ranges

resource "aws_security_group_rule" "service_ssh_in" {
  type              = "ingress"
  description       = "SSH Allowed"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.cidr_blocks_whitelist_ssh_in
  security_group_id = aws_security_group.sg_sparkmain.id
}

# Default egress policy permissive for users to be able to install their own packages - conditional

resource "aws_security_group_rule" "sg_egress" {
  type              = "egress"
  description       = "Host egress rules"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_sparkmain.id
}
