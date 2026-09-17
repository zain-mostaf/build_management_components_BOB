###############################################################################
# modules/vpc/variables.tf
###############################################################################

variable "create_vpc" {
  description = "When true, create a new VPC. When false, look up an existing VPC by name."
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "Name of the VPC to create or look up."
  type        = string

  validation {
    condition     = length(trimspace(var.vpc_name)) > 0
    error_message = "vpc_name must not be empty."
  }
}

variable "resource_group_id" {
  description = "Resource Group ID to associate with the VPC (only used when create_vpc = true)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Optional list of tags to apply to the VPC."
  type        = list(string)
  default     = []
}
