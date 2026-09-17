###############################################################################
# modules/security_group/variables.tf
###############################################################################

variable "create_security_group" {
  description = "When true, create a new Security Group with rules. When false, look up an existing one by name."
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Name of the Security Group to create or look up. Must match IBM Cloud VPC naming rules: lowercase letters, digits, and hyphens only; must start with a letter and end with a letter or digit."
  type        = string

  validation {
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.security_group_name))
    error_message = "security_group_name must start with a lowercase letter, contain only lowercase letters, digits, and hyphens, and end with a letter or digit. Underscores are not allowed."
  }
}

variable "vpc_id" {
  description = "VPC ID that the Security Group belongs to."
  type        = string
}

variable "resource_group_id" {
  description = "Resource Group ID (required when create_security_group = true)."
  type        = string
  default     = null
}

variable "security_group_rules" {
  description = <<-EOT
    List of Security Group rules to create (only used when create_security_group = true).
    Each object supports:
      direction  – "inbound" or "outbound"
      remote     – CIDR or Security Group ID
      protocol   – "tcp", "udp", "icmp", or "all"
      port_min   – Minimum TCP/UDP port (optional, used with tcp/udp)
      port_max   – Maximum TCP/UDP port (optional, used with tcp/udp)
      icmp_type  – ICMP type (optional, used with icmp)
      icmp_code  – ICMP code (optional, used with icmp)
  EOT
  type = list(object({
    direction  = string
    remote     = string
    protocol   = string
    port_min   = optional(number, null)
    port_max   = optional(number, null)
    icmp_type  = optional(number, null)
    icmp_code  = optional(number, null)
  }))
  default = []
}
