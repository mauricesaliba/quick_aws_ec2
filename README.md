# Terraform Lab 01 — Amazon Linux 2023 EC2 on a new VPC

Provisions a single Amazon Linux 2023 (x86_64) EC2 instance inside a brand-new
VPC. Access mode is selected at apply time via the `access_mode` variable:

| Mode | How it works |
|---|---|
| `ssh` | Port 22 opened **only to your current public IP**; EC2 key pair injected |
| `ssm` | No ports opened; instance connects to SSM via internet gateway; access via `aws ssm start-session` |

> All commands are for **Git Bash** on Windows.

---

## What this project creates

| Resource | Name | Notes |
|---|---|---|
| VPC | `lab01-vpc` | CIDR `10.0.0.0/16`, DNS enabled |
| Internet Gateway | `lab01-igw` | Attached to the VPC |
| Public Subnet | `lab01-public-subnet` | CIDR `10.0.1.0/24`, auto-assign public IP |
| Route Table | `lab01-public-rt` | Default route `0.0.0.0/0 → IGW` |
| Security Group | `lab01-sg` | SSH ingress on port 22 only in `ssh` mode |
| Key Pair | `demo-test` | Created in `ssh` mode only |
| IAM Role + Profile | `lab01-ssm-role` | Created in `ssm` mode only; grants `AmazonSSMManagedInstanceCore` |
| EC2 Instance | `lab01-instance` | AL2023, `t3.micro`, 20 GB gp3 encrypted root volume |

---

## Prerequisites

### 1. AWS CLI profile

This project uses the **`Management`** profile already configured in
`~/.aws/config` and `~/.aws/credentials` (region: `eu-central-1`).

Switch to it and confirm the active identity before running Terraform:

```bash
export AWS_PROFILE=Management
aws sts get-caller-identity
```

### 2. SSH key (ssh mode only)

Copy `demo-test.pem` into your SSH folder:

```bash
cp /path/to/demo-test.pem ~/.ssh/demo-test.pem
```

Extract the public key (required once — Terraform uploads this to AWS):

```bash
ssh-keygen -y -f ~/.ssh/demo-test.pem > ~/.ssh/demo-test.pub
```

Fix permissions so SSH accepts it:

```bash
chmod 400 ~/.ssh/demo-test.pem
```

### 3. Session Manager plugin (ssm mode only)

Install the AWS Session Manager plugin so `aws ssm start-session` works locally:
https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

### 4. Terraform >= 1.5

```bash
terraform -version
```

---

## How to run

### Init (first time only)

```bash
terraform init
```

### SSH mode

Port 22 is opened to your current public IP. A key pair is uploaded to AWS.

```bash
terraform apply -var="access_mode=ssh"
```

Connect using the `connect_command` output:

```bash
ssh -i ~/.ssh/demo-test.pem ec2-user@<instance_public_ip>
```

### SSM mode

No ports are opened. The instance is given an IAM profile that allows the SSM
agent to call home through the internet gateway.

```bash
terraform apply -var="access_mode=ssm"
```

#### Connecting via SSM

**Step 1 — make sure your profile is active:**

```bash
export AWS_PROFILE=Management
```

**Step 2 — wait ~60 seconds** after apply for the SSM agent to register, then
start a session using the `instance_id` from the Terraform output:

```bash
aws ssm start-session --target <instance_id>
```

This opens an interactive shell directly in your terminal — no key pair or open
ports required. You land as `ssm-user`. To switch to the default `ec2-user`:

```bash
sudo su - ec2-user
```

**Verify the instance is reachable before connecting:**

```bash
aws ssm describe-instance-information \
  --filters "Key=InstanceIds,Values=<instance_id>" \
  --query "InstanceInformationList[0].PingStatus"
```

The instance is ready when the output is `"Online"`.

**Terminate the session** by typing `exit` or pressing `Ctrl+D`.

### Output after apply

```
Outputs:

access_mode        = "ssh"   # or "ssm"
ami_id             = "ami-0abcdef1234567890"
connect_command    = "ssh -i ~/.ssh/demo-test.pem ec2-user@54.123.45.67"
instance_id        = "i-0abcdef1234567890"
instance_public_ip = "54.123.45.67"
operator_ip        = "203.0.113.10/32"
```

---

## Overridable variables

| Variable | Default | Description |
|---|---|---|
| `access_mode` | `"ssh"` | `"ssh"` or `"ssm"` |
| `aws_profile` | `"Management"` | AWS CLI named profile |
| `aws_region` | `"eu-central-1"` | AWS region |
| `vpc_cidr` | `"10.0.0.0/16"` | VPC CIDR block |
| `subnet_cidr` | `"10.0.1.0/24"` | Public subnet CIDR |
| `availability_zone` | `""` (auto) | Leave empty to use first available AZ |
| `instance_type` | `"t3.micro"` | EC2 instance type |
| `key_name` | `"demo-test"` | Key pair name in AWS (ssh mode only) |
| `private_key_path` | `"~/.ssh/demo-test.pem"` | Path to private key (used in output only) |
| `public_key_path` | `"~/.ssh/demo-test.pub"` | Path to public key uploaded to AWS (ssh mode only) |
| `project_tag` | `"lab01"` | `Project` tag applied to all resources |

---

## Switching modes

If you applied in one mode and want to switch, just re-apply with the other value.
Terraform will destroy the mode-specific resources (key pair or IAM profile) and
create the new ones:

```bash
terraform apply -var="access_mode=ssm"
```

---

## Teardown

```bash
terraform destroy -var="access_mode=<the mode you applied with>"
```

This removes **all** resources created by this project.
