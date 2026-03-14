# Key pair is only uploaded to AWS when access_mode = "ssh"
# Private key: ~/.ssh/demo-test.pem  (never leaves your machine)
# Public key:  ~/.ssh/demo-test.pub  (extracted from the .pem — see README)
resource "aws_key_pair" "main" {
  count = var.access_mode == "ssh" ? 1 : 0

  key_name   = var.key_name
  public_key = file(var.public_key_path)

  tags = {
    Name    = var.key_name
    Project = var.project_tag
  }
}

resource "aws_instance" "main" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.main.id]

  # Attached only in ssh mode
  key_name = var.access_mode == "ssh" ? aws_key_pair.main[0].key_name : null

  # Attached only in ssm mode — grants the instance SSM agent permissions
  iam_instance_profile = var.access_mode == "ssm" ? aws_iam_instance_profile.ssm[0].name : null

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name    = "${var.project_tag}-instance"
    Project = var.project_tag
  }
}
