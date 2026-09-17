###############################################################################
# modules/ssh_key/main.tf
#
# Create-or-use-existing pattern for IBM Cloud VPC SSH keys.
#
# IMPORTANT – Windows image compatibility:
#   IBM Cloud does NOT support ED25519 SSH keys with Windows images.
#   The caller must supply key_type = "rsa" when the key will be used
#   with Windows VSIs.  A validation rule in variables.tf enforces this.
###############################################################################

# ── CREATE ────────────────────────────────────────────────────────────────────
resource "ibm_is_ssh_key" "this" {
  count          = var.create_ssh_key ? 1 : 0
  name           = var.ssh_key_name
  public_key     = var.public_key
  type           = var.key_type
  resource_group = var.resource_group_id
}

# ── LOOKUP ────────────────────────────────────────────────────────────────────
data "ibm_is_ssh_key" "this" {
  count = var.create_ssh_key ? 0 : 1
  name  = var.ssh_key_name
}

# ── RESOLVED VALUES ───────────────────────────────────────────────────────────
locals {
  id       = var.create_ssh_key ? ibm_is_ssh_key.this[0].id       : data.ibm_is_ssh_key.this[0].id
  name     = var.create_ssh_key ? ibm_is_ssh_key.this[0].name     : data.ibm_is_ssh_key.this[0].name
  key_type = var.create_ssh_key ? ibm_is_ssh_key.this[0].type     : data.ibm_is_ssh_key.this[0].type
}
