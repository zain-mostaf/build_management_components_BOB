###############################################################################
# modules/security_group/variables.tf
###############################################################################

variable "create_security_group" {
  description = "When true, create a new Security Group with rules. When false, look up an existing one by name."
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Name of the Security Group to create or look up."
  type        = string

  validation {
    condition     = length(trimspace(var.security_group_name)) > 0
    error_message = "security_group_name must not be empty."
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
