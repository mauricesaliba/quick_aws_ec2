# Resolve the latest Amazon Linux 2023 x86_64 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Resolve the public IP of the machine running Terraform
# Used to restrict SSH ingress to this machine only
data "http" "my_public_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  # Strip trailing newline returned by checkip and append /32
  my_cidr = "${chomp(data.http.my_public_ip.response_body)}/32"

  # Use the variable AZ if set, otherwise fall back to first AZ in the region
  availability_zone = var.availability_zone != "" ? var.availability_zone : data.aws_availability_zones.available.names[0]
}

data "aws_availability_zones" "available" {
  state = "available"
}
