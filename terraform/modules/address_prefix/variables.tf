###############################################################################
# modules/address_prefix/variables.tf
###############################################################################

variable "create_address_prefix" {
  description = "When true, create a new VPC address prefix. When false, look up an existing one by name."
  type        = bool
  default     = true
}

variable "address_prefix_name" {
  description = "Name of the address prefix to create or look up."
  type        = string

  validation {
    condition     = length(trimspace(var.address_prefix_name)) > 0
    error_message = "address_prefix_name must not be empty."
  }
}

variable "vpc_id" {
  description = "VPC ID that owns this address prefix."
  type        = string
}

variable "zone" {
  description = "Zone in which to create the address prefix (e.g. us-south-1)."
  type        = string
}

variable "address_prefix_cidr" {
  description = "CIDR block for the address prefix (required when create_address_prefix = true)."
  type        = string
  default     = null
}
