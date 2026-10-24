output "host" {
  value       = data.aws_instance.live.public_ip
  description = "empty while stopped"
}

output "user" {
  value = var.ssh_user
}

output "id" {
  value = aws_instance.this.id
}

output "state" {
  value = aws_ec2_instance_state.this.state
}

# --- aws

output "region" {
  value = var.region
}

output "role" {
  value       = aws_iam_role.this.name
  description = "instance role; attach extra policies to it"
}

output "ami" {
  value = aws_instance.this.ami
}
