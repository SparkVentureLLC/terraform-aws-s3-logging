output "public_ip" {
 value       = aws_instance.ec2_vm.public_ip
 description = "Public IP Address of EC2 instance"
}

output "SSHAccessCommand" {
  value = "ssh ubuntu@${aws_instance.ec2_vm.public_ip}"
}
