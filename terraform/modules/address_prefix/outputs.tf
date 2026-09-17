###############################################################################
# modules/address_prefix/outputs.tf
###############################################################################

output "id" {
  description = "Address prefix ID (created or looked-up)."
  value       = local.id
}

output "cidr" {
  description = "CIDR block of the address prefix (created or looked-up)."
  value       = local.cidr
}

output "name" {
  description = "Name of the address prefix (created or looked-up)."
  value       = local.name
}
