###############################################################################
# modules/resource_group/variables.tf
###############################################################################

variable "create_resource_group" {
  description = "When true, create a new Resource Group. When false, look up an existing one by name."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create or look up."
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name must not be empty."
  }
}
