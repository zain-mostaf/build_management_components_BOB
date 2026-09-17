###############################################################################
# modules/vsi_windows/variables.tf
###############################################################################

variable "number_of_instances" {
  description = "Number of Windows VSIs to create."
  type        = number
  default     = 1

  validation {
    condition     = var.number_of_instances >= 0
    error_message = "number_of_instances must be >= 0."
  }
}

variable "hostname_prefix" {
  description = "Prefix for generated hostnames. A hyphen and index are appended (e.g. 'wdccom-win-jh' → wdccom-win-jh-1). Must follow IBM Cloud VPC naming rules: start with a lowercase letter, end with a letter or digit, hyphens allowed in the middle."
  type        = string
  default     = "wdccom-win-jh"

  validation {
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.hostname_prefix))
    error_message = "hostname_prefix must start with a lowercase letter, contain only lowercase letters, digits, and hyphens, and end with a letter or digit. Underscores are not allowed."
  }
}

variable "vpc_id" {
  description = "VPC ID for the VSI."
  type        = string
}

variable "zone" {
  description = "Zone for the VSI (e.g. us-south-1)."
  type        = string
}

variable "image_id" {
  description = "ID of the Windows OS image to use."
  type        = string
}

variable "profile" {
  description = "VSI profile (e.g. bx2-4x16)."
  type        = string
  default     = "bx2-4x16"
}

variable "resource_group_id" {
  description = "Resource Group ID."
  type        = string
}

variable "ssh_key_id" {
  description = <<-EOT
    Optional RSA SSH key ID.  When provided, IBM Cloud uses the corresponding
    private key to decrypt the initial Windows administrator password.
    NOTE: ED25519 keys are NOT supported by IBM Cloud Windows images.
    Set to null to omit SSH key attachment.
  EOT
  type    = string
  default = null
}

variable "subnet_id" {
  description = "Subnet ID for the primary network interface."
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR used for IP calculation via cidrhost()."
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID to attach to the network interface."
  type        = string
}

variable "start_ip_offset" {
  description = <<-EOT
    Offset from the subnet base address for the first Windows VSI's private IP.
    IBM Cloud reserves offsets 0–3 in every subnet; minimum value is 4.
    Must not overlap with the Linux VSI IP range.
  EOT
  type    = number
  default = 10

  validation {
    condition     = var.start_ip_offset >= 4
    error_message = "start_ip_offset must be >= 4 (IBM Cloud reserves offsets 0–3 in every subnet)."
  }
}

variable "use_vni" {
  description = "When true, use VNI-based network attachment. When false, use inline primary_network_interface."
  type        = bool
  default     = false
}

variable "vni_ids" {
  description = "List of VNI IDs (one per instance). Required when use_vni = true."
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "Optional user_data script (e.g. PowerShell for WinRM configuration)."
  type        = string
  default     = null
}
