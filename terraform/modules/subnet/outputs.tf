###############################################################################
# modules/subnet/outputs.tf
###############################################################################

output "id" {
  description = "Subnet ID (created or looked-up)."
  value       = local.id
}

output "name" {
  description = "Subnet name (created or looked-up)."
  value       = local.name
}

output "cidr" {
  description = "Subnet IPv4 CIDR block (created or looked-up)."
  value       = local.cidr
}

output "zone" {
  description = "Zone in which the subnet resides."
  value       = local.zone
}
