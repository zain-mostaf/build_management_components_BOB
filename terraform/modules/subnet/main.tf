###############################################################################
# modules/subnet/main.tf
#
# Create-or-use-existing pattern for IBM Cloud VPC Subnets.
#
# Notes on IBM Cloud reserved IPs per subnet:
#   .0  – Network address
#   .1  – Default gateway
#   .2  – DNS resolver
#   .3  – Reserved for future use
#   .255 (or last address) – Broadcast
#
# Do NOT allocate private IPs at these offsets from the subnet base.
# The minimum safe offset for VSI allocation is 4.
###############################################################################

# ── CREATE ────────────────────────────────────────────────────────────────────
resource "ibm_is_subnet" "this" {
  count           = var.create_subnet ? 1 : 0
  name            = var.subnet_name
  vpc             = var.vpc_id
  zone            = var.zone
  ipv4_cidr_block = var.subnet_cidr
  resource_group  = var.resource_group_id

  # Use the VPC default network ACL (no custom ACL)
  network_acl = var.default_network_acl_id

  # Use the VPC default routing table (no custom route table)
  routing_table = var.default_routing_table_id
}

# ── LOOKUP ────────────────────────────────────────────────────────────────────
data "ibm_is_subnet" "this" {
  count = var.create_subnet ? 0 : 1
  name  = var.subnet_name

  # IBM provider ≥ 1.54 supports the `name` argument on the subnet data source.
  # The VPC and zone constraints are validated post-lookup via a precondition.
}

# ── VALIDATION (lookup only) ─────────────────────────────────────────────────
# Terraform 1.5+ check blocks run as assertions without requiring provider resources.
check "subnet_vpc_membership" {
  assert {
    condition     = var.create_subnet || data.ibm_is_subnet.this[0].vpc == var.vpc_id
    error_message = "The existing subnet '${var.subnet_name}' does not belong to the expected VPC."
  }
}

check "subnet_zone_membership" {
  assert {
    condition     = var.create_subnet || data.ibm_is_subnet.this[0].zone == var.zone
    error_message = "The existing subnet '${var.subnet_name}' is not in the expected zone '${var.zone}'."
  }
}

# ── RESOLVED VALUES ───────────────────────────────────────────────────────────
locals {
  id   = var.create_subnet ? ibm_is_subnet.this[0].id            : data.ibm_is_subnet.this[0].id
  name = var.create_subnet ? ibm_is_subnet.this[0].name          : data.ibm_is_subnet.this[0].name
  cidr = var.create_subnet ? ibm_is_subnet.this[0].ipv4_cidr_block : data.ibm_is_subnet.this[0].ipv4_cidr_block
  zone = var.create_subnet ? ibm_is_subnet.this[0].zone          : data.ibm_is_subnet.this[0].zone
}
