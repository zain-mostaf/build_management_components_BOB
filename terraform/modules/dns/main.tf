###############################################################################
# modules/dns/main.tf
#
# IBM Cloud DNS Services — create-or-use-existing pattern covering:
#   • DNS Services instance  (ibm_resource_instance / data source)
#   • DNS zone               (ibm_dns_zone / data source lookup)
#   • DNS A records          (ibm_dns_resource_record  type=A)
#   • DNS PTR records        (ibm_dns_resource_record  type=PTR)
#
# DNS instance lookup:
#   IBM Cloud does not have a dedicated DNS-instance data source; we use the
#   generic ibm_resource_instance data source filtered by service=dns-svcs.
#
# DNS zone lookup:
#   We list all zones in the instance and filter by name locally because
#   ibm_dns_zone does not have a standalone data source in the IBM provider.
###############################################################################

# ── DNS INSTANCE ──────────────────────────────────────────────────────────────
resource "ibm_resource_instance" "dns" {
  count             = var.create_dns_instance ? 1 : 0
  name              = var.dns_instance_name
  resource_group_id = var.resource_group_id
  service           = "dns-svcs"
  plan              = "standard-dns"
  location          = "global"
}

data "ibm_resource_instance" "dns" {
  count             = var.create_dns_instance ? 0 : 1
  name              = var.dns_instance_name
  resource_group_id = var.resource_group_id
  service           = "dns-svcs"
}

locals {
  dns_instance_id   = var.create_dns_instance ? ibm_resource_instance.dns[0].id   : data.ibm_resource_instance.dns[0].id
  dns_instance_name = var.create_dns_instance ? ibm_resource_instance.dns[0].name : data.ibm_resource_instance.dns[0].name

  # ibm_resource_instance exposes the GUID separately from the CRN-based id.
  # DNS zone and record resources require the instance GUID.
  dns_instance_guid = var.create_dns_instance ? ibm_resource_instance.dns[0].guid : data.ibm_resource_instance.dns[0].guid
}

# ── DNS ZONE ──────────────────────────────────────────────────────────────────
resource "ibm_dns_zone" "this" {
  count       = var.create_dns_zone ? 1 : 0
  name        = var.dns_zone_name
  instance_id = local.dns_instance_guid
  description = "Managed by Terraform"
  label       = var.dns_zone_label
}

# Lookup: enumerate all zones for the instance, filter by name locally.
data "ibm_dns_zones" "all" {
  count       = var.create_dns_zone ? 0 : 1
  instance_id = local.dns_instance_guid
}

locals {
  existing_zone = var.create_dns_zone ? null : [
    for z in data.ibm_dns_zones.all[0].dns_zones :
    z if z.name == var.dns_zone_name
  ]

  dns_zone_id   = var.create_dns_zone ? ibm_dns_zone.this[0].zone_id : local.existing_zone[0].zone_id
  dns_zone_name = var.create_dns_zone ? ibm_dns_zone.this[0].name    : local.existing_zone[0].name
}

# ── A RECORDS ─────────────────────────────────────────────────────────────────
# One A record per Linux VSI
resource "ibm_dns_resource_record" "linux_a" {
  count       = length(var.linux_hostnames)
  instance_id = local.dns_instance_guid
  zone_id     = local.dns_zone_id
  type        = "A"
  name        = var.linux_hostnames[count.index]
  rdata       = var.linux_ips[count.index]
  ttl         = var.dns_ttl
}

# One A record per Windows VSI
resource "ibm_dns_resource_record" "windows_a" {
  count       = length(var.windows_hostnames)
  instance_id = local.dns_instance_guid
  zone_id     = local.dns_zone_id
  type        = "A"
  name        = var.windows_hostnames[count.index]
  rdata       = var.windows_ips[count.index]
  ttl         = var.dns_ttl
}

# ── PTR RECORDS ───────────────────────────────────────────────────────────────
# PTR name format expected by IBM Cloud DNS:
#   Reverse the IP octets and append ".in-addr.arpa"
#   e.g. 10.136.64.4 → 4.64.136.10.in-addr.arpa

locals {
  linux_ptr_names = [
    for ip in var.linux_ips :
    join(".", reverse(split(".", ip)))
  ]

  windows_ptr_names = [
    for ip in var.windows_ips :
    join(".", reverse(split(".", ip)))
  ]
}

resource "ibm_dns_resource_record" "linux_ptr" {
  count       = length(var.linux_hostnames)
  instance_id = local.dns_instance_guid
  zone_id     = local.dns_zone_id
  type        = "PTR"
  name        = local.linux_ptr_names[count.index]
  rdata       = "${var.linux_hostnames[count.index]}.${var.dns_zone_name}"
  ttl         = var.dns_ttl
}

resource "ibm_dns_resource_record" "windows_ptr" {
  count       = length(var.windows_hostnames)
  instance_id = local.dns_instance_guid
  zone_id     = local.dns_zone_id
  type        = "PTR"
  name        = local.windows_ptr_names[count.index]
  rdata       = "${var.windows_hostnames[count.index]}.${var.dns_zone_name}"
  ttl         = var.dns_ttl
}
