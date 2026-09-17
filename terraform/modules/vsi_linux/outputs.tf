###############################################################################
# modules/vsi_linux/outputs.tf
###############################################################################

output "ids" {
  description = "List of Linux VSI IDs."
  value       = ibm_is_instance.this[*].id
}

output "names" {
  description = "List of Linux VSI hostnames."
  value       = ibm_is_instance.this[*].name
}

output "private_ips" {
  description = "List of assigned private IP addresses."
  value       = local.private_ips
}

output "hostnames" {
  description = "Generated hostnames in order (e.g. ['jump01', 'jump02'])."
  value       = local.hostnames
}
