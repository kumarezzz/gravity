output "ec2_instance_publicip" {
  description = "EC2 Instance public IP"
  value = aws_instance.ec2.public_ip 
}
output "ec2_security_groups" {
  description = "List Security Groups associated with EC2 Instance"
  value = aws_instance.ec2.security_groups
}