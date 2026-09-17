###############################################################################
# modules/ssh_key/outputs.tf
###############################################################################

output "id" {
  description = "SSH key ID (created or looked-up)."
  value       = local.id
}

output "name" {
  description = "SSH key name (created or looked-up)."
  value       = local.name
}

output "key_type" {
  description = "SSH key type ('rsa' or 'ed25519')."
  value       = local.key_type
}
