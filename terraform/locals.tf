###############################################################################
# locals.tf
#
# All computed values used across root-level module calls are centralised here.
# This keeps main.tf clean and makes cross-cutting validations easy to see.
###############################################################################

locals {
  # ── IP RANGE COMPUTATION ──────────────────────────────────────────────────

  # The subnet CIDR is known only after subnet resolution; we use the output
  # from the subnet module which is available once plan/apply computes it.
  # For the validation locals below we accept var.subnet_cidr which is either
  # set directly (create_subnet=true) or looked up (create_subnet=false).
  # The subnet module always outputs the actual CIDR so we can use it safely.

  # Pre-compute every Linux private IP
  linux_private_ips = [
    for i in range(var.number_of_jump_servers) :
    cidrhost(module.subnet.cidr, var.linux_start_ip_offset + i)
  ]

  # Pre-compute every Windows private IP
  windows_private_ips = [
    for i in range(var.number_of_windows_servers) :
    cidrhost(module.subnet.cidr, var.windows_start_ip_offset + i)
  ]

  # Linux hostname list
  linux_hostnames = [
    for i in range(var.number_of_jump_servers) :
    format("%s%02d", var.linux_hostname_prefix, i + 1)
  ]

  # Windows hostname list
  windows_hostnames = [
    for i in range(var.number_of_windows_servers) :
    format("%s%02d", var.windows_hostname_prefix, i + 1)
  ]

  # ── IP OVERLAP VALIDATION ─────────────────────────────────────────────────

  # Compute all allocated offsets for each group
  linux_offsets   = toset([for i in range(var.number_of_jump_servers) : var.linux_start_ip_offset + i])
  windows_offsets = toset([for i in range(var.number_of_windows_servers) : var.windows_start_ip_offset + i])

  # Any offset that appears in both sets is an overlap
  ip_overlap = setintersection(local.linux_offsets, local.windows_offsets)

  # ── HOSTNAME DUPLICATE CHECK ──────────────────────────────────────────────

  # All hostnames across both groups (duplicates are dangerous for DNS)
  all_hostnames = concat(local.linux_hostnames, local.windows_hostnames)
}
