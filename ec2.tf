# Associate our local SSH public key with this Instance
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = file("${var.ssh_public_key_file}")
}

# Creating Ubuntu EC2 instance
# Default user: Ubuntu
resource "aws_instance" "ec2_vm" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.sg_sparkmain.id ]
  tags = {
    Name = var.ec2_name
  }
}