###############################################################################
# modules/dns/variables.tf
###############################################################################

# ── DNS INSTANCE ──────────────────────────────────────────────────────────────
variable "create_dns_instance" {
  description = "When true, create a new DNS Services instance. When false, look up by name."
  type        = bool
  default     = true
}

variable "dns_instance_name" {
  description = "Name of the DNS Services instance to create or look up."
  type        = string

  validation {
    condition     = length(trimspace(var.dns_instance_name)) > 0
    error_message = "dns_instance_name must not be empty."
  }
}

variable "resource_group_id" {
  description = "Resource Group ID for the DNS instance (required when create_dns_instance = true)."
  type        = string
  default     = null
}

# ── DNS ZONE ──────────────────────────────────────────────────────────────────
variable "create_dns_zone" {
  description = "When true, create a new DNS zone. When false, look up by name."
  type        = bool
  default     = true
}

variable "dns_zone_name" {
  description = "DNS zone name (e.g. example.internal)."
  type        = string

  validation {
    condition     = length(trimspace(var.dns_zone_name)) > 0
    error_message = "dns_zone_name must not be empty."
  }
}

variable "dns_zone_label" {
  description = "Optional label for the DNS zone (only used when create_dns_zone = true)."
  type        = string
  default     = ""
}

variable "dns_ttl" {
  description = "TTL (seconds) for DNS records."
  type        = number
  default     = 300
}

# ── A / PTR RECORD DATA ───────────────────────────────────────────────────────
variable "linux_hostnames" {
  description = "List of Linux VSI short hostnames (e.g. ['jump01', 'jump02'])."
  type        = list(string)
  default     = []
}

variable "linux_ips" {
  description = "List of Linux VSI private IPs aligned by index with linux_hostnames."
  type        = list(string)
  default     = []
}

variable "windows_hostnames" {
  description = "List of Windows VSI short hostnames (e.g. ['win01', 'win02'])."
  type        = list(string)
  default     = []
}

variable "windows_ips" {
  description = "List of Windows VSI private IPs aligned by index with windows_hostnames."
  type        = list(string)
  default     = []
}
