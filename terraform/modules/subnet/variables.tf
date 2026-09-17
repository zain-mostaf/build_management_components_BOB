###############################################################################
# modules/subnet/variables.tf
###############################################################################

variable "create_subnet" {
  description = "When true, create a new subnet. When false, look up an existing subnet by name."
  type        = bool
  default     = true
}

variable "subnet_name" {
  description = "Name of the subnet to create or look up."
  type        = string

  validation {
    condition     = length(trimspace(var.subnet_name)) > 0
    error_message = "subnet_name must not be empty."
  }
}

variable "vpc_id" {
  description = "VPC ID that the subnet belongs to."
  type        = string
}

variable "zone" {
  description = "Zone for the subnet (e.g. us-south-1)."
  type        = string
}

variable "subnet_cidr" {
  description = "IPv4 CIDR block for the subnet (required when create_subnet = true)."
  type        = string
  default     = null
}

variable "resource_group_id" {
  description = "Resource Group ID (required when create_subnet = true)."
  type        = string
  default     = null
}

variable "default_network_acl_id" {
  description = "VPC default Network ACL ID. Used to explicitly attach the subnet to the default ACL."
  type        = string
  default     = null
}

variable "default_routing_table_id" {
  description = "VPC default routing table ID. Used to explicitly attach the subnet to the default route table."
  type        = string
  default     = null
}
