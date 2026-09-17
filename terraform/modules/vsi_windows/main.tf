###############################################################################
# modules/vsi_windows/main.tf
#
# Provisions one or more Windows VSIs using ibm_is_instance.
#
# Key differences from Linux VSIs:
#   • SSH keys are optional and must be RSA (not ED25519).
#   • Windows images retrieve the initial administrator password via the
#     IBM Cloud console or API using the RSA private key — Terraform does
#     not expose it as a resource attribute.
#   • The user_data field can be used to pass a PowerShell script for
#     initial configuration (e.g. enabling WinRM).
#
# IP allocation:
#   cidrhost(subnet_cidr, start_ip_offset + index)
#   IBM Cloud reserved offsets: 0–3 (and broadcast). Min offset: 4.
###############################################################################

locals {
  private_ips = [
    for i in range(var.number_of_instances) :
    cidrhost(var.subnet_cidr, var.start_ip_offset + i)
  ]

  # Unique hostnames: <prefix>-<zero-padded-index>  e.g. wdccom-win-jh-01, wdccom-win-jh-02
  hostnames = [
    for i in range(var.number_of_instances) :
    format("%s-%02d", var.hostname_prefix, i + 1)
  ]
}

# ── VSI ───────────────────────────────────────────────────────────────────────
resource "ibm_is_instance" "this" {
  count          = var.number_of_instances
  name           = local.hostnames[count.index]
  vpc            = var.vpc_id
  zone           = var.zone
  image          = var.image_id
  profile        = var.profile
  resource_group = var.resource_group_id

  # SSH key is optional for Windows; when provided it must be RSA.
  keys = var.ssh_key_id != null ? [var.ssh_key_id] : []

  lifecycle {
    precondition {
      # Verify the computed IP is within the subnet CIDR.
      condition     = cidrhost(var.subnet_cidr, var.start_ip_offset + count.index) != ""
      error_message = "Computed IP for Windows instance index ${count.index} is invalid. Check start_ip_offset and number_of_instances against the subnet size."
    }
  }

  # Optional user_data for WinRM / initial configuration scripts.
  user_data = var.user_data

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

  # VNI-based primary attachment — used when use_vni = true.
  # The IBM Cloud provider requires primary_network_attachment (not
  # network_attachments) to satisfy the
  # primary_network_attachment|primary_network_interface constraint.
  dynamic "primary_network_attachment" {
    for_each = var.use_vni ? [1] : []
    content {
      name = "${local.hostnames[count.index]}-nic"
      virtual_network_interface {
        id = var.vni_ids[count.index]
      }
    }
  }
}
