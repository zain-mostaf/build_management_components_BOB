###############################################################################
# modules/vpc/main.tf
#
# Create-or-use-existing pattern for IBM Cloud VPCs.
###############################################################################

# ── CREATE ────────────────────────────────────────────────────────────────────
resource "ibm_is_vpc" "this" {
  count               = var.create_vpc ? 1 : 0
  name                = var.vpc_name
  resource_group      = var.resource_group_id
  address_prefix_management = "manual"

  tags = var.tags
}

# ── LOOKUP ────────────────────────────────────────────────────────────────────
data "ibm_is_vpc" "this" {
  count = var.create_vpc ? 0 : 1
  name  = var.vpc_name
}

# ── RESOLVED VALUES ───────────────────────────────────────────────────────────
locals {
  id   = var.create_vpc ? ibm_is_vpc.this[0].id   : data.ibm_is_vpc.this[0].id
  name = var.create_vpc ? ibm_is_vpc.this[0].name : data.ibm_is_vpc.this[0].name

  # Default Network ACL — used by subnets to avoid creating custom ACLs.
  default_network_acl_id    = var.create_vpc ? ibm_is_vpc.this[0].default_network_acl : data.ibm_is_vpc.this[0].default_network_acl

  # Default routing table — used by subnets to avoid creating custom route tables.
  default_routing_table_id  = var.create_vpc ? ibm_is_vpc.this[0].default_routing_table : data.ibm_is_vpc.this[0].default_routing_table
}
