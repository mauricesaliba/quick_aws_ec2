variable "aws_profile" {
  description = "AWS CLI named profile to use for authentication"
  type        = string
  default     = "Management"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "AZ for the subnet (leave empty to use first available)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name to assign to the EC2 key pair in AWS"
  type        = string
  default     = "demo-test"
}

# Place demo-test.pem at: ~/.ssh/demo-test.pem  (C:\Users\mauri\.ssh\demo-test.pem)
# Extract the public key once:  ssh-keygen -y -f ~/.ssh/demo-test.pem > ~/.ssh/demo-test.pub
# Fix permissions:              chmod 400 ~/.ssh/demo-test.pem
variable "private_key_path" {
  description = "Path to the SSH private key (.pem) — used only in the ssh_command output"
  type        = string
  default     = "~/.ssh/demo-test.pem"
}

variable "public_key_path" {
  description = "Path to the SSH public key extracted from the .pem (demo-test.pub)"
  type        = string
  default     = "~/.ssh/demo-test.pub"
}

variable "project_tag" {
  description = "Value for the Project tag applied to all resources"
  type        = string
  default     = "lab01"
}

variable "access_mode" {
  description = "How to access the instance: 'ssh' (port 22 + key pair) or 'ssm' (Session Manager, no open ports)"
  type        = string
  default     = "ssh"

  validation {
    condition     = contains(["ssh", "ssm"], var.access_mode)
    error_message = "access_mode must be either 'ssh' or 'ssm'."
  }
}
