###############################################################################
# variables.tf — Root module variables
###############################################################################

# ── GLOBAL ────────────────────────────────────────────────────────────────────
variable "ibmcloud_api_key" {
  description = "IBM Cloud API key. Set via TF_VAR_ibmcloud_api_key or terraform.tfvars."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region (e.g. us-south, eu-de)."
  type        = string
  default     = "us-east"
}

variable "tags" {
  description = "Optional list of tags applied to created resources."
  type        = list(string)
  default     = []
}

# ── RESOURCE GROUP ────────────────────────────────────────────────────────────
variable "create_resource_group" {
  description = "When true, create a new Resource Group. When false, look up an existing one by name."
  type        = bool
  default     = false
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create or use."
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name must not be empty."
  }
}

# ── VPC ───────────────────────────────────────────────────────────────────────
variable "create_vpc" {
  description = "When true, create a new VPC. When false, look up an existing VPC by name."
  type        = bool
  default     = false
}

variable "vpc_name" {
  description = "Name of the VPC to create or use."
  type        = string
  default     = "wdccom-vpc-common"

  validation {
    condition     = length(trimspace(var.vpc_name)) > 0
    error_message = "vpc_name must not be empty."
  }
}

# ── ADDRESS PREFIX ────────────────────────────────────────────────────────────
variable "create_address_prefix" {
  description = "When true, create a VPC address prefix. When false, look up an existing one."
  type        = bool
  default     = false
}

variable "address_prefix_name" {
  description = "Name of the address prefix to create or use. Must match IBM Cloud VPC naming rules: lowercase letters, digits, and hyphens only; must start with a letter and end with a letter or digit."
  type        = string
  default     = "wdccom-vpc-common-prefix"

  validation {
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.address_prefix_name))
    error_message = "address_prefix_name must start with a lowercase letter, contain only lowercase letters, digits, and hyphens, and end with a letter or digit. Underscores are not allowed."
  }
}

variable "address_prefix_cidr" {
  description = "CIDR block for the address prefix (required when create_address_prefix = true)."
  type        = string
  default     = null
}

# ── SUBNET ────────────────────────────────────────────────────────────────────
variable "create_subnet" {
  description = "When true, create a new subnet. When false, look up an existing subnet by name."
  type        = bool
  default     = false
}

variable "subnet_name" {
  description = "Name of the subnet to create or use. Must match IBM Cloud VPC naming rules: lowercase letters, digits, and hyphens only; must start with a letter and end with a letter or digit."
  type        = string
  default     = "wdccom-vpc-common-subnet"

  validation {
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.subnet_name))
    error_message = "subnet_name must start with a lowercase letter, contain only lowercase letters, digits, and hyphens, and end with a letter or digit. Underscores are not allowed."
  }
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet (required when create_subnet = true)."
  type        = string
  default     = null
}

variable "zone" {
  description = "IBM Cloud zone (e.g. us-south-1)."
  type        = string
  default     = "us-east-1"
}

# ── SECURITY GROUP ────────────────────────────────────────────────────────────
variable "create_security_group" {
  description = "When true, create a new Security Group. When false, look up by name."
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Name of the Security Group to create or use. Must match IBM Cloud VPC naming rules: lowercase letters, digits, and hyphens only; must start with a letter and end with a letter or digit."
  type        = string
  default     = "wdccom-management-sg"

  validation {
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.security_group_name))
    error_message = "security_group_name must start with a lowercase letter, contain only lowercase letters, digits, and hyphens, and end with a letter or digit. Underscores are not allowed."
  }
}

variable "security_group_rules" {
  description = "Security Group rules (only used when create_security_group = true)."
  type = list(object({
    direction  = string
    remote     = string
    protocol   = string
    port_min   = optional(number, null)
    port_max   = optional(number, null)
    icmp_type  = optional(number, null)
    icmp_code  = optional(number, null)
  }))
  default = [
    {
      direction = "inbound"
      remote    = "0.0.0.0/0"
      protocol  = "all"
    },
    {
      direction = "outbound"
      remote    = "0.0.0.0/0"
      protocol  = "all"
    }
  ]
}

# ── SSH KEY ───────────────────────────────────────────────────────────────────
variable "create_ssh_key" {
  description = "When true, create a new SSH key. When false, look up by name."
  type        = bool
  default     = true
}

variable "ssh_key_name" {
  description = "Name of the SSH key to create or use."
  type        = string
  default     = "wdccom-internal-key"

  validation {
    condition     = length(trimspace(var.ssh_key_name)) > 0
    error_message = "ssh_key_name must not be empty."
  }
}

variable "ssh_public_key" {
  description = "SSH public key material (required when create_ssh_key = true)."
  type        = string
  default     = null
  sensitive   = true
}

variable "ssh_key_type" {
  description = <<-EOT
    SSH key type: 'rsa' or 'ed25519'.
    IMPORTANT: IBM Cloud Windows images do NOT support ed25519 keys.
    Use 'rsa' when the key will be attached to Windows VSIs.
  EOT
  type    = string
  default = "rsa"

  validation {
    condition     = contains(["rsa", "ed25519"], var.ssh_key_type)
    error_message = "ssh_key_type must be 'rsa' or 'ed25519'."
  }
}

variable "attach_ssh_key_to_windows" {
  description = <<-EOT
    When true, the same SSH key is attached to Windows VSIs (for password decryption).
    Only valid when ssh_key_type = 'rsa'. ED25519 keys are NOT supported by Windows images.
  EOT
  type    = bool
  default = true

  validation {
    condition     = !(var.attach_ssh_key_to_windows && var.ssh_key_type == "ed25519")
    error_message = "attach_ssh_key_to_windows = true requires ssh_key_type = 'rsa'. IBM Cloud Windows images do not support ED25519 keys."
  }
}

# ── VNI ───────────────────────────────────────────────────────────────────────
variable "use_vni" {
  description = "When true, create Virtual Network Interfaces. When false, use inline primary_network_interface."
  type        = bool
  default     = true
}

# ── LINUX VSI ─────────────────────────────────────────────────────────────────
variable "number_of_jump_servers" {
  description = "Number of Linux Jump Server VSIs to create."
  type        = number
  default     = 1

  validation {
    condition     = var.number_of_jump_servers >= 0
    error_message = "number_of_jump_servers must be >= 0."
  }
}

variable "linux_hostname_prefix" {
  description = "Prefix for Linux VSI hostnames. A hyphen and index are appended automatically (e.g. 'wdccom-jump-host' → wdccom-jump-host-1). Must follow IBM Cloud VPC naming rules: start with a lowercase letter, end with a letter or digit, contain only lowercase letters, digits, and hyphens."
  type        = string
  default     = "wdccom-jump-host"

  validation {
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.linux_hostname_prefix))
    error_message = "linux_hostname_prefix must start with a lowercase letter, contain only lowercase letters, digits, and hyphens, and end with a letter or digit. Underscores are not allowed."
  }
}

variable "linux_image_id" {
  description = "IBM Cloud VPC image ID for the Linux OS."
  type        = string
}

variable "linux_profile" {
  description = "VSI profile for Linux instances (e.g. bx2-2x8)."
  type        = string
  default     = "cx2-32x64"
}

variable "linux_start_ip_offset" {
  description = <<-EOT
    IP offset from the subnet base address for the first Linux VSI.
    IBM Cloud reserves offsets 0–3 in every subnet. Minimum value: 4.
    Example: subnet 10.136.64.0/22, offset 4 → first Linux IP = 10.136.64.4
  EOT
  type    = number
  default = 5

  validation {
    condition     = var.linux_start_ip_offset >= 4
    error_message = "linux_start_ip_offset must be >= 4 (offsets 0–3 are reserved by IBM Cloud)."
  }
}

# ── WINDOWS VSI ───────────────────────────────────────────────────────────────
variable "number_of_windows_servers" {
  description = "Number of Windows VSIs to create."
  type        = number
  default     = 1

  validation {
    condition     = var.number_of_windows_servers >= 0
    error_message = "number_of_windows_servers must be >= 0."
  }
}

variable "windows_hostname_prefix" {
  description = "Prefix for Windows VSI hostnames. A hyphen and index are appended automatically (e.g. 'wdccom-win-jh' → wdccom-win-jh-1). Must follow IBM Cloud VPC naming rules: start with a lowercase letter, end with a letter or digit, contain only lowercase letters, digits, and hyphens."
  type        = string
  default     = "wdccom-win-jh"

  validation {
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.windows_hostname_prefix))
    error_message = "windows_hostname_prefix must start with a lowercase letter, contain only lowercase letters, digits, and hyphens, and end with a letter or digit. Underscores are not allowed."
  }
}

variable "windows_image_id" {
  description = "IBM Cloud VPC image ID for the Windows OS."
  type        = string
}

variable "windows_profile" {
  description = "VSI profile for Windows instances (e.g. bx2-4x16)."
  type        = string
  default     = "bx2-2x8"
}

variable "windows_start_ip_offset" {
  description = <<-EOT
    IP offset from the subnet base address for the first Windows VSI.
    IBM Cloud reserves offsets 0–3. Minimum value: 4.
    Must not overlap with the Linux IP range.
    Example: offset 10, 2 servers → 10.136.64.10, 10.136.64.11
  EOT
  type    = number
  default = 7

  validation {
    condition     = var.windows_start_ip_offset >= 4
    error_message = "windows_start_ip_offset must be >= 4 (offsets 0–3 are reserved by IBM Cloud)."
  }
}

variable "windows_user_data" {
  description = "Optional PowerShell user_data script for Windows VSI initialisation (e.g. WinRM enablement)."
  type        = string
  default     = null
}

# ── ACTIVE DIRECTORY SERVER ───────────────────────────────────────────────────
variable "ad_hostname_prefix" {
  description = "Prefix for the AD server hostname. A hyphen and zero-padded index are appended (e.g. 'wdccom-ad' → wdccom-ad-01). Must follow IBM Cloud VPC naming rules."
  type        = string
  default     = "wdccom-ad"

  validation {
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.ad_hostname_prefix))
    error_message = "ad_hostname_prefix must start with a lowercase letter, contain only lowercase letters, digits, and hyphens, and end with a letter or digit."
  }
}

variable "ad_start_ip_offset" {
  description = <<-EOT
    IP offset from the subnet base address for the AD server.
    IBM Cloud reserves offsets 0–3. Must not overlap with Linux or Windows ranges.
    Default: 12 (safe after Linux offsets 4–5 and Windows offsets 10–11).
  EOT
  type    = number
  default = 10

  validation {
    condition     = var.ad_start_ip_offset >= 4
    error_message = "ad_start_ip_offset must be >= 4 (offsets 0–3 are reserved by IBM Cloud)."
  }
}

variable "ad_user_data" {
  description = "Optional PowerShell user_data script for AD server initialisation."
  type        = string
  default     = null
}

# ── DNS ───────────────────────────────────────────────────────────────────────
variable "create_dns_instance" {
  description = "When true, create a new IBM Cloud DNS Services instance. When false, look up by name."
  type        = bool
  default     = true
}

variable "dns_instance_name" {
  description = "Name of the DNS Services instance to create or use."
  type        = string

  validation {
    condition     = length(trimspace(var.dns_instance_name)) > 0
    error_message = "dns_instance_name must not be empty."
  }
}

variable "create_dns_zone" {
  description = "When true, create a new DNS zone. When false, look up by name."
  type        = bool
  default     = true
}

variable "dns_zone_name" {
  description = "DNS zone name (e.g. hpc.example.internal)."
  type        = string

  validation {
    condition     = length(trimspace(var.dns_zone_name)) > 0
    error_message = "dns_zone_name must not be empty."
  }
}

variable "dns_ttl" {
  description = "TTL in seconds for DNS records."
  type        = number
  default     = 43200
}
