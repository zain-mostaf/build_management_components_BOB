###############################################################################
# modules/dns/outputs.tf
###############################################################################

output "dns_instance_id" {
  description = "DNS Services instance CRN/ID (created or looked-up)."
  value       = local.dns_instance_id
}

output "dns_instance_guid" {
  description = "DNS Services instance GUID (used by dns_zone and dns_resource_record resources)."
  value       = local.dns_instance_guid
}

output "dns_instance_name" {
  description = "DNS Services instance name."
  value       = local.dns_instance_name
}

output "dns_zone_id" {
  description = "DNS zone ID (created or looked-up)."
  value       = local.dns_zone_id
}

output "dns_zone_name" {
  description = "DNS zone name."
  value       = local.dns_zone_name
}

output "linux_a_record_ids" {
  description = "IDs of the Linux A records."
  value       = ibm_dns_resource_record.linux_a[*].id
}

output "windows_a_record_ids" {
  description = "IDs of the Windows A records."
  value       = ibm_dns_resource_record.windows_a[*].id
}

output "linux_ptr_record_ids" {
  description = "IDs of the Linux PTR records."
  value       = ibm_dns_resource_record.linux_ptr[*].id
}

output "windows_ptr_record_ids" {
  description = "IDs of the Windows PTR records."
  value       = ibm_dns_resource_record.windows_ptr[*].id
}
