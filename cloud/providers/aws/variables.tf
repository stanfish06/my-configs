variable "name" {
  type        = string
  description = "vm name: hostname, ssh alias, resource name prefix"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,30}$", var.name))
    error_message = "name: lowercase letters, digits and dashes, starting with a letter, max 31 chars."
  }
}

variable "ssh_pubkey" {
  type        = string
  description = "authorized key for ssh_user"
}

variable "ssh_cidrs" {
  type        = list(string)
  description = "sources allowed to reach ssh and mosh"
}

variable "running" {
  type    = bool
  default = true
}

variable "instance_type" {
  type        = string
  default     = "m8i-flex.xlarge"
  description = "docker sandboxes need /dev/kvm: c8i, m8i, r8i and their flex variants, or a metal type"
}

variable "disk_gb" {
  type    = number
  default = 100
}

variable "image" {
  type        = string
  default     = ""
  description = "image id; empty picks the latest ubuntu_release image for the instance type's arch"
}

variable "ssh_user" {
  type        = string
  default     = "ubuntu"
  description = "login user of the image"
}

# --- aws

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "empty picks a default-VPC subnet in an AZ that offers instance_type"
}

variable "disk_type" {
  type    = string
  default = "gp3"
}

variable "ubuntu_release" {
  type        = string
  default     = "resolute-26.04"
  description = "codename-version in canonical's AMI names"
}

variable "nested_virtualization" {
  type        = bool
  default     = null
  description = "null enables it on 8th-gen intel types (c8i, m8i, r8i)"
}

variable "imds_hop_limit" {
  type        = number
  default     = 1
  description = "1 keeps the instance role away from containers; 2 lets docker containers use it"
}

variable "s3_buckets" {
  type        = list(string)
  default     = []
  description = "buckets the instance role can reach"
}

variable "s3_write" {
  type        = bool
  default     = true
  description = "false grants read-only access to s3_buckets"
}
