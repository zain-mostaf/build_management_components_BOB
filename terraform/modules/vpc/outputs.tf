###############################################################################
# modules/vpc/outputs.tf
###############################################################################

output "id" {
  description = "VPC ID (created or looked-up)."
  value       = local.id
}

output "name" {
  description = "VPC name (created or looked-up)."
  value       = local.name
}

output "default_network_acl_id" {
  description = "Default Network ACL ID of the VPC."
  value       = local.default_network_acl_id
}

output "default_routing_table_id" {
  description = "Default routing table ID of the VPC."
  value       = local.default_routing_table_id
}
