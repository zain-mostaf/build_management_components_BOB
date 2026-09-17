###############################################################################
# modules/vni/variables.tf
###############################################################################

variable "use_vni" {
  description = "When true, create Virtual Network Interfaces (VNIs). When false, no resources are created."
  type        = bool
  default     = false
}

variable "count_instances" {
  description = "Number of VNIs to create (should match the number of VSIs)."
  type        = number
  default     = 0
}

variable "name_prefix" {
  description = "Prefix used to generate VNI names (e.g. 'jump' → 'jump01-vni')."
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID to attach the VNI to."
  type        = string
  default     = null
}

variable "subnet_cidr" {
  description = "Subnet CIDR used to calculate the fixed private IP via cidrhost()."
  type        = string
  default     = null
}

variable "start_ip_offset" {
  description = "IP offset from the subnet base for the first VNI (e.g. 4 → first usable host after reserved IPs)."
  type        = number
  default     = 4
}

variable "security_group_id" {
  description = "Security Group ID to attach to each VNI."
  type        = string
  default     = null
}

variable "resource_group_id" {
  description = "Resource Group ID for the VNIs."
  type        = string
  default     = null
}
