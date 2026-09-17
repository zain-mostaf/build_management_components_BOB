###############################################################################
# modules/security_group/main.tf
#
# Create-or-use-existing pattern for IBM Cloud VPC Security Groups.
# Rules are only created when create_security_group = true.
###############################################################################

# ── CREATE ────────────────────────────────────────────────────────────────────
resource "ibm_is_security_group" "this" {
  count          = var.create_security_group ? 1 : 0
  name           = var.security_group_name
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
}

# ── RULES (only when creating) ────────────────────────────────────────────────
resource "ibm_is_security_group_rule" "this" {
  for_each = var.create_security_group ? {
    for idx, rule in var.security_group_rules : tostring(idx) => rule
  } : {}

  group     = ibm_is_security_group.this[0].id
  direction = each.value.direction
  remote    = each.value.remote

  dynamic "tcp" {
    for_each = each.value.protocol == "tcp" ? [each.value] : []
    content {
      port_min = tcp.value.port_min
      port_max = tcp.value.port_max
    }
  }

  dynamic "udp" {
    for_each = each.value.protocol == "udp" ? [each.value] : []
    content {
      port_min = udp.value.port_min
      port_max = udp.value.port_max
    }
  }

  dynamic "icmp" {
    for_each = each.value.protocol == "icmp" ? [each.value] : []
    content {
      type = icmp.value.icmp_type
      code = icmp.value.icmp_code
    }
  }
}

# ── LOOKUP ────────────────────────────────────────────────────────────────────
data "ibm_is_security_group" "this" {
  count = var.create_security_group ? 0 : 1
  name  = var.security_group_name
  vpc   = var.vpc_id
}

# ── RESOLVED VALUES ───────────────────────────────────────────────────────────
locals {
  id   = var.create_security_group ? ibm_is_security_group.this[0].id   : data.ibm_is_security_group.this[0].id
  name = var.create_security_group ? ibm_is_security_group.this[0].name : data.ibm_is_security_group.this[0].name
}
