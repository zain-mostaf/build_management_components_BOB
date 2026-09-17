###############################################################################
# outputs.tf — Root module outputs
###############################################################################

# ── RESOURCE GROUP ────────────────────────────────────────────────────────────
output "resource_group_id" {
  description = "Resource Group ID."
  value       = module.resource_group.id
}

output "resource_group_name" {
  description = "Resource Group name."
  value       = module.resource_group.name
}

# ── VPC ───────────────────────────────────────────────────────────────────────
output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.id
}

output "vpc_name" {
  description = "VPC name."
  value       = module.vpc.name
}

# ── SUBNET ────────────────────────────────────────────────────────────────────
output "subnet_id" {
  description = "Subnet ID."
  value       = module.subnet.id
}

output "subnet_name" {
  description = "Subnet name."
  value       = module.subnet.name
}

output "subnet_cidr" {
  description = "Subnet CIDR block."
  value       = module.subnet.cidr
}

# ── SECURITY GROUP ────────────────────────────────────────────────────────────
output "security_group_id" {
  description = "Security Group ID."
  value       = module.security_group.id
}

output "security_group_name" {
  description = "Security Group name."
  value       = module.security_group.name
}

# ── SSH KEY ───────────────────────────────────────────────────────────────────
output "ssh_key_id" {
  description = "SSH key ID."
  value       = module.ssh_key.id
}

output "ssh_key_name" {
  description = "SSH key name."
  value       = module.ssh_key.name
}

# ── DNS ───────────────────────────────────────────────────────────────────────
output "dns_instance_id" {
  description = "DNS Services instance ID/CRN."
  value       = module.dns.dns_instance_id
}

output "dns_instance_name" {
  description = "DNS Services instance name."
  value       = module.dns.dns_instance_name
}

output "dns_zone_id" {
  description = "DNS zone ID."
  value       = module.dns.dns_zone_id
}

output "dns_zone_name" {
  description = "DNS zone name."
  value       = module.dns.dns_zone_name
}

# ── LINUX VSIs ────────────────────────────────────────────────────────────────
output "linux_vsi_ids" {
  description = "List of Linux VSI IDs."
  value       = module.vsi_linux.ids
}

output "linux_vsi_names" {
  description = "List of Linux VSI names."
  value       = module.vsi_linux.names
}

output "linux_vsi_private_ips" {
  description = "List of Linux VSI private IP addresses."
  value       = module.vsi_linux.private_ips
}

output "linux_dns_records" {
  description = "Map of Linux VSI hostname → private IP (for quick reference)."
  value = {
    for i, hostname in module.vsi_linux.hostnames :
    "${hostname}.${var.dns_zone_name}" => module.vsi_linux.private_ips[i]
  }
}

# ── WINDOWS VSIs ──────────────────────────────────────────────────────────────
output "windows_vsi_ids" {
  description = "List of Windows VSI IDs."
  value       = module.vsi_windows.ids
}

output "windows_vsi_names" {
  description = "List of Windows VSI names."
  value       = module.vsi_windows.names
}

output "windows_vsi_private_ips" {
  description = "List of Windows VSI private IP addresses."
  value       = module.vsi_windows.private_ips
}

output "windows_dns_records" {
  description = "Map of Windows VSI hostname → private IP (for quick reference)."
  value = {
    for i, hostname in module.vsi_windows.hostnames :
    "${hostname}.${var.dns_zone_name}" => module.vsi_windows.private_ips[i]
  }
}

# ── AD SERVER ─────────────────────────────────────────────────────────────────
output "ad_vsi_id" {
  description = "AD server VSI ID."
  value       = module.vsi_ad.ids[0]
}

output "ad_vsi_name" {
  description = "AD server VSI hostname."
  value       = module.vsi_ad.names[0]
}

output "ad_vsi_private_ip" {
  description = "AD server private IP address."
  value       = module.vsi_ad.private_ips[0]
}
