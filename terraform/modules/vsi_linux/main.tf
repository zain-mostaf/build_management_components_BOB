###############################################################################
# modules/vsi_linux/main.tf
#
# Provisions one or more Linux VSIs (Jump Servers) using ibm_is_instance.
#
# IP allocation model:
#   Each VSI receives:  cidrhost(subnet_cidr, start_ip_offset + index)
#
#   IBM Cloud reserves the following offsets inside every subnet:
#     +0  network address
#     +1  default gateway
#     +2  DNS resolver
#     +3  reserved for future use
#     last address – broadcast
#   → The minimum safe start_ip_offset is 4.
#
# Two networking modes are supported, selected by use_vni:
#   use_vni = false (default)
#     Primary Network Interface is defined inline on the instance resource.
#   use_vni = true
#     A VNI is pre-created by the caller's vni module and passed in via
#     vni_ids; the instance uses network_attachments instead.
###############################################################################

locals {
  # Pre-compute the private IP for every instance index.
  private_ips = [
    for i in range(var.number_of_instances) :
    cidrhost(var.subnet_cidr, var.start_ip_offset + i)
  ]

  # Unique hostnames: <prefix><zero-padded-index>  e.g. jump01, jump02
  hostnames = [
    for i in range(var.number_of_instances) :
    format("%s%02d", var.hostname_prefix, i + 1)
  ]
}

# ── VSI (primary network interface mode) ─────────────────────────────────────
resource "ibm_is_instance" "this" {
  count          = var.number_of_instances
  name           = local.hostnames[count.index]
  vpc            = var.vpc_id
  zone           = var.zone
  image          = var.image_id
  profile        = var.profile
  resource_group = var.resource_group_id

  keys = [var.ssh_key_id]

  lifecycle {
    precondition {
      # Verify the computed IP is within the subnet CIDR.
      # cidrhost() will error on its own if the offset exceeds the subnet,
      # but this gives a cleaner, explicit message.
      condition     = cidrhost(var.subnet_cidr, var.start_ip_offset + count.index) != ""
      error_message = "Computed IP for instance index ${count.index} is invalid. Check start_ip_offset and number_of_instances against the subnet size."
    }
  }

  # Inline network interface — used when use_vni = false
  dynamic "primary_network_interface" {
    for_each = var.use_vni ? [] : [1]
    content {
      subnet          = var.subnet_id
      security_groups = [var.security_group_id]

      primary_ip {
        address     = local.private_ips[count.index]
        auto_delete = true
      }
    }
  }

  # VNI-based network attachment — used when use_vni = true
  dynamic "network_attachments" {
    for_each = var.use_vni ? [1] : []
    content {
      name                    = "${local.hostnames[count.index]}-nic"
      virtual_network_interface {
        id = var.vni_ids[count.index]
      }
    }
  }

  # When using VNI, the primary_network_attachment must point to the VNI.
  # The primary_network_interface block is not used in that case.
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────
# (see outputs.tf)
