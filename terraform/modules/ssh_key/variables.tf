###############################################################################
# modules/ssh_key/variables.tf
###############################################################################

variable "create_ssh_key" {
  description = "When true, create a new SSH key. When false, look up an existing key by name."
  type        = bool
  default     = true
}

variable "ssh_key_name" {
  description = "Name of the SSH key to create or look up."
  type        = string

  validation {
    condition     = length(trimspace(var.ssh_key_name)) > 0
    error_message = "ssh_key_name must not be empty."
  }
}

variable "public_key" {
  description = "SSH public key material (required when create_ssh_key = true)."
  type        = string
  default     = null
  sensitive   = true
}

variable "key_type" {
  description = <<-EOT
    Type of SSH key: "rsa" or "ed25519".
    NOTE: IBM Cloud Windows images do NOT support ED25519 keys.
    Use "rsa" for any key that will be attached to Windows VSIs.
  EOT
  type    = string
  default = "rsa"

  validation {
    condition     = contains(["rsa", "ed25519"], var.key_type)
    error_message = "key_type must be either 'rsa' or 'ed25519'."
  }
}

variable "resource_group_id" {
  description = "Resource Group ID (required when create_ssh_key = true)."
  type        = string
  default     = null
}
