# IAM resources are only created when access_mode = "ssm"

resource "aws_iam_role" "ssm" {
  count = var.access_mode == "ssm" ? 1 : 0

  name = "${var.project_tag}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name    = "${var.project_tag}-ssm-role"
    Project = var.project_tag
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.access_mode == "ssm" ? 1 : 0

  role       = aws_iam_role.ssm[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  count = var.access_mode == "ssm" ? 1 : 0

  name = "${var.project_tag}-ssm-profile"
  role = aws_iam_role.ssm[0].name

  tags = {
    Name    = "${var.project_tag}-ssm-profile"
    Project = var.project_tag
  }
}
