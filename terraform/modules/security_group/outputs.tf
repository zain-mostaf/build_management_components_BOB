###############################################################################
# modules/security_group/outputs.tf
###############################################################################

output "id" {
  description = "Security Group ID (created or looked-up)."
  value       = local.id
}

output "name" {
  description = "Security Group name (created or looked-up)."
  value       = local.name
}
