###############################################################################
# modules/vni/main.tf
#
# Virtual Network Interface (VNI) module.
#
# This module creates one VNI per VSI when use_vni = true.
# Each VNI is associated with a subnet, a fixed private IP, and a security
# group, then returned as a list so the caller can attach it to a VSI via a
# network_attachments block.
#
# When use_vni = false this module creates nothing — the caller uses a
# primary_network_interface block directly on ibm_is_instance instead.
###############################################################################

# ── CREATE VNIs ───────────────────────────────────────────────────────────────
resource "ibm_is_virtual_network_interface" "this" {
  count             = var.use_vni ? var.count_instances : 0
  name              = "${var.name_prefix}${format("%02d", count.index + 1)}-vni"
  subnet            = var.subnet_id
  resource_group    = var.resource_group_id
  allow_ip_spoofing = false

  primary_ip {
    address     = cidrhost(var.subnet_cidr, var.start_ip_offset + count.index)
    auto_delete = true
  }

  security_groups = [var.security_group_id]
}
