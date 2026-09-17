###############################################################################
# modules/address_prefix/main.tf
#
# Create-or-use-existing pattern for VPC Address Prefixes.
###############################################################################

# ── CREATE ────────────────────────────────────────────────────────────────────
resource "ibm_is_vpc_address_prefix" "this" {
  count = var.create_address_prefix ? 1 : 0
  name  = var.address_prefix_name
  vpc   = var.vpc_id
  zone  = var.zone
  cidr  = var.address_prefix_cidr
}

# ── LOOKUP ────────────────────────────────────────────────────────────────────
# IBM Cloud does not expose a dedicated data source for a single address prefix
# by name, so we enumerate all prefixes for the VPC and filter locally.
data "ibm_is_vpc_address_prefixes" "all" {
  count = var.create_address_prefix ? 0 : 1
  vpc   = var.vpc_id
}

locals {
  # Filter the list to find the prefix with the matching name.
  existing_prefix = var.create_address_prefix ? null : [
    for p in data.ibm_is_vpc_address_prefixes.all[0].address_prefixes :
    p if p.name == var.address_prefix_name
  ]

  id   = var.create_address_prefix ? ibm_is_vpc_address_prefix.this[0].id   : local.existing_prefix[0].id
  cidr = var.create_address_prefix ? ibm_is_vpc_address_prefix.this[0].cidr : local.existing_prefix[0].cidr
  name = var.create_address_prefix ? ibm_is_vpc_address_prefix.this[0].name : local.existing_prefix[0].name
}
