###############################################################################
# modules/address_prefix/variables.tf
###############################################################################

variable "create_address_prefix" {
  description = "When true, create a new VPC address prefix. When false, look up an existing one by name."
  type        = bool
  default     = true
}

variable "address_prefix_name" {
  description = "Name of the address prefix to create or look up. Must match IBM Cloud VPC naming rules: lowercase letters, digits, and hyphens only; must start with a letter and end with a letter or digit."
  type        = string

  validation {
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.address_prefix_name))
    error_message = "address_prefix_name must start with a lowercase letter, contain only lowercase letters, digits, and hyphens, and end with a letter or digit. Underscores are not allowed."
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
