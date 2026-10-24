module "cloud_init" {
  source     = "../../modules/cloud-init"
  hostname   = var.name
  ssh_pubkey = var.ssh_pubkey
}

locals {
  arch   = contains(data.aws_ec2_instance_type.this.supported_architectures, "arm64") ? "arm64" : "amd64"
  nested = var.nested_virtualization != null ? var.nested_virtualization : can(regex("^[cmr]8i", var.instance_type))
}

data "aws_ec2_instance_type" "this" {
  instance_type = var.instance_type
}

data "aws_ami" "ubuntu" {
  count       = var.image == "" ? 1 : 0
  most_recent = true
  owners      = ["099720109477"] # canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-${var.ubuntu_release}-${local.arch}-server-*"]
  }
}

data "aws_ec2_instance_type_offerings" "this" {
  location_type = "availability-zone"

  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }

  filter {
    name   = "availability-zone"
    values = data.aws_ec2_instance_type_offerings.this.locations
  }
}

data "aws_subnet" "this" {
  id = coalesce(var.subnet_id, try(sort(data.aws_subnets.default.ids)[0], null))
}

resource "aws_security_group" "this" {
  name_prefix = "cloud-${var.name}-"
  description = "cloud vm: ssh and mosh from ssh_cidrs"
  vpc_id      = data.aws_subnet.this.vpc_id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidrs
  }

  ingress {
    description = "mosh"
    from_port   = 60000
    to_port     = 61000
    protocol    = "udp"
    cidr_blocks = var.ssh_cidrs
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "this" {
  ami                    = var.image != "" ? var.image : data.aws_ami.ubuntu[0].id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.this.id
  vpc_security_group_ids = [aws_security_group.this.id]
  iam_instance_profile   = aws_iam_instance_profile.this.name
  user_data              = module.cloud_init.user_data

  # /dev/kvm inside the vm for docker sandboxes
  dynamic "cpu_options" {
    for_each = local.nested ? [1] : []
    content {
      nested_virtualization = "enabled"
    }
  }

  root_block_device {
    volume_size = var.disk_gb
    volume_type = var.disk_type
    encrypted   = true
  }

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = var.imds_hop_limit
  }

  tags = {
    Name = var.name
  }

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

resource "aws_ec2_instance_state" "this" {
  instance_id = aws_instance.this.id
  state       = var.running ? "running" : "stopped"
}

# read after start/stop so outputs carry the new public IP
data "aws_instance" "live" {
  instance_id = aws_instance.this.id
  depends_on  = [aws_ec2_instance_state.this]
}
