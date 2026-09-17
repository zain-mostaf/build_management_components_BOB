###############################################################################
# modules/resource_group/main.tf
#
# Create-or-use-existing pattern for IBM Cloud Resource Groups.
# When create_resource_group = true  → ibm_resource_group is created.
# When create_resource_group = false → ibm_resource_group data source is used.
###############################################################################

# ── CREATE ────────────────────────────────────────────────────────────────────
resource "ibm_resource_group" "this" {
  count = var.create_resource_group ? 1 : 0
  name  = var.resource_group_name
}

# ── LOOKUP ────────────────────────────────────────────────────────────────────
data "ibm_resource_group" "this" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

# ── RESOLVED VALUES (used by callers) ─────────────────────────────────────────
locals {
  id   = var.create_resource_group ? ibm_resource_group.this[0].id   : data.ibm_resource_group.this[0].id
  name = var.create_resource_group ? ibm_resource_group.this[0].name : data.ibm_resource_group.this[0].name
}
