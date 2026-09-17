###############################################################################
# modules/resource_group/outputs.tf
###############################################################################

output "id" {
  description = "Resource Group ID (created or looked-up)."
  value       = local.id
}

output "name" {
  description = "Resource Group name (created or looked-up)."
  value       = local.name
}
