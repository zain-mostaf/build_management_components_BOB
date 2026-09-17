###############################################################################
# modules/vni/outputs.tf
###############################################################################

output "ids" {
  description = "List of VNI IDs in index order (empty when use_vni = false)."
  value       = ibm_is_virtual_network_interface.this[*].id
}
