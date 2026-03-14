output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "access_mode" {
  description = "Access mode used for this deployment"
  value       = var.access_mode
}

output "connect_command" {
  description = "Ready-to-use command to connect to the instance"
  value = var.access_mode == "ssh" ? (
    "ssh -i ~/.ssh/demo-test.pem ec2-user@${aws_instance.main.public_ip}"
  ) : (
    "aws ssm start-session --target ${aws_instance.main.id} --profile ${var.aws_profile} --region ${var.aws_region}"
  )
}

output "operator_ip" {
  description = "IP locked into the SSH security group rule (ssh mode only)"
  value       = var.access_mode == "ssh" ? local.my_cidr : "N/A — SSM mode, port 22 is closed"
}

output "ami_id" {
  description = "Amazon Linux 2023 AMI resolved at apply time"
  value       = data.aws_ami.al2023.id
}
