resource "aws_security_group" "main" {
  name        = "${var.project_tag}-sg"
  description = "Instance security group - SSH ingress only active in ssh mode"
  vpc_id      = aws_vpc.main.id

  # Port 22 is opened only when access_mode = "ssh", locked to the operator IP
  dynamic "ingress" {
    for_each = var.access_mode == "ssh" ? [1] : []
    content {
      description = "SSH from operator IP only"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [local.my_cidr]
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_tag}-sg"
    Project = var.project_tag
  }
}
