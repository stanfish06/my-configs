variable "hostname" {
  type = string
}

variable "ssh_pubkey" {
  type        = string
  description = "authorized key for the image's default user"
}

output "user_data" {
  value = "#cloud-config\n${yamlencode({
    hostname            = var.hostname
    manage_etc_hosts    = true
    ssh_authorized_keys = [trimspace(var.ssh_pubkey)]
  })}"
}
