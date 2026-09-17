###############################################################################
# main.tf — Root module
#
# Orchestrates all child modules in dependency order:
#   resource_group → vpc → address_prefix → subnet
#                                         → security_group
#                                         → ssh_key
#                                         → vni (linux)
#                                         → vni (windows)
#                                         → vsi_linux
#                                         → vsi_windows
#                                         → dns
###############################################################################

# ── CROSS-CUTTING ASSERTIONS (Terraform 1.5+ check blocks) ───────────────────
# These assertions evaluate once the plan data is available.
# Note: check blocks cannot be referenced in depends_on — the VSI modules
# contain equivalent preconditions directly on their resources (see below).

check "ip_range_no_overlap" {
  assert {
    condition     = length(local.ip_overlap) == 0
    error_message = "Linux and Windows IP ranges overlap at subnet offsets: ${join(", ", local.ip_overlap)}. Adjust linux_start_ip_offset or windows_start_ip_offset."
  }
}

check "no_duplicate_hostnames" {
  assert {
    condition     = length(local.all_hostnames) == length(toset(local.all_hostnames))
    error_message = "Duplicate hostnames detected. Change linux_hostname_prefix or windows_hostname_prefix to avoid DNS collisions."
  }
}

# ── 1. RESOURCE GROUP ─────────────────────────────────────────────────────────
module "resource_group" {
  source = "./modules/resource_group"

  create_resource_group = var.create_resource_group
  resource_group_name   = var.resource_group_name
}

# ── 2. VPC ────────────────────────────────────────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  create_vpc        = var.create_vpc
  vpc_name          = var.vpc_name
  resource_group_id = module.resource_group.id
  tags              = var.tags
}

# ── 3. ADDRESS PREFIX ─────────────────────────────────────────────────────────
module "address_prefix" {
  source = "./modules/address_prefix"

  create_address_prefix = var.create_address_prefix
  address_prefix_name   = var.address_prefix_name
  vpc_id                = module.vpc.id
  zone                  = var.zone
  address_prefix_cidr   = var.address_prefix_cidr
}

# ── 4. SUBNET ─────────────────────────────────────────────────────────────────
module "subnet" {
  source = "./modules/subnet"

  create_subnet            = var.create_subnet
  subnet_name              = var.subnet_name
  vpc_id                   = module.vpc.id
  zone                     = var.zone
  subnet_cidr              = var.subnet_cidr
  resource_group_id        = module.resource_group.id
  default_network_acl_id   = module.vpc.default_network_acl_id
  default_routing_table_id = module.vpc.default_routing_table_id
}

# ── 5. SECURITY GROUP ─────────────────────────────────────────────────────────
module "security_group" {
  source = "./modules/security_group"

  create_security_group = var.create_security_group
  security_group_name   = var.security_group_name
  vpc_id                = module.vpc.id
  resource_group_id     = module.resource_group.id
  security_group_rules  = var.security_group_rules
}

# ── 6. SSH KEY ────────────────────────────────────────────────────────────────
module "ssh_key" {
  source = "./modules/ssh_key"

  create_ssh_key    = var.create_ssh_key
  ssh_key_name      = var.ssh_key_name
  public_key        = var.ssh_public_key
  key_type          = var.ssh_key_type
  resource_group_id = module.resource_group.id
}

# ── 7. VNI — LINUX ────────────────────────────────────────────────────────────
module "vni_linux" {
  source = "./modules/vni"

  use_vni           = var.use_vni
  count_instances   = var.number_of_jump_servers
  name_prefix       = var.linux_hostname_prefix
  subnet_id         = module.subnet.id
  subnet_cidr       = module.subnet.cidr
  start_ip_offset   = var.linux_start_ip_offset
  security_group_id = module.security_group.id
  resource_group_id = module.resource_group.id
}

# ── 8. VNI — WINDOWS ─────────────────────────────────────────────────────────
module "vni_windows" {
  source = "./modules/vni"

  use_vni           = var.use_vni
  count_instances   = var.number_of_windows_servers
  name_prefix       = var.windows_hostname_prefix
  subnet_id         = module.subnet.id
  subnet_cidr       = module.subnet.cidr
  start_ip_offset   = var.windows_start_ip_offset
  security_group_id = module.security_group.id
  resource_group_id = module.resource_group.id
}

# ── 9. LINUX VSIs ─────────────────────────────────────────────────────────────
module "vsi_linux" {
  source = "./modules/vsi_linux"

  number_of_instances = var.number_of_jump_servers
  hostname_prefix     = var.linux_hostname_prefix
  vpc_id              = module.vpc.id
  zone                = var.zone
  image_id            = var.linux_image_id
  profile             = var.linux_profile
  resource_group_id   = module.resource_group.id
  ssh_key_id          = module.ssh_key.id
  subnet_id           = module.subnet.id
  subnet_cidr         = module.subnet.cidr
  security_group_id   = module.security_group.id
  start_ip_offset     = var.linux_start_ip_offset
  use_vni             = var.use_vni
  vni_ids             = module.vni_linux.ids

}

# ── 10. WINDOWS VSIs ──────────────────────────────────────────────────────────
module "vsi_windows" {
  source = "./modules/vsi_windows"

  number_of_instances = var.number_of_windows_servers
  hostname_prefix     = var.windows_hostname_prefix
  vpc_id              = module.vpc.id
  zone                = var.zone
  image_id            = var.windows_image_id
  profile             = var.windows_profile
  resource_group_id   = module.resource_group.id
  # Attach SSH key only when the caller opts in AND the key type is RSA.
  ssh_key_id          = var.attach_ssh_key_to_windows ? module.ssh_key.id : null
  subnet_id           = module.subnet.id
  subnet_cidr         = module.subnet.cidr
  security_group_id   = module.security_group.id
  start_ip_offset     = var.windows_start_ip_offset
  use_vni             = var.use_vni
  vni_ids             = module.vni_windows.ids
  user_data           = var.windows_user_data
}

# ── 11. VNI — AD SERVER ───────────────────────────────────────────────────────
module "vni_ad" {
  source = "./modules/vni"

  use_vni           = var.use_vni
  count_instances   = 1
  name_prefix       = var.ad_hostname_prefix
  subnet_id         = module.subnet.id
  subnet_cidr       = module.subnet.cidr
  start_ip_offset   = var.ad_start_ip_offset
  security_group_id = module.security_group.id
  resource_group_id = module.resource_group.id
}

# ── 12. AD SERVER VSI ─────────────────────────────────────────────────────────
module "vsi_ad" {
  source = "./modules/vsi_windows"

  number_of_instances = 1
  hostname_prefix     = var.ad_hostname_prefix
  vpc_id              = module.vpc.id
  zone                = var.zone
  image_id            = var.windows_image_id
  profile             = var.windows_profile
  resource_group_id   = module.resource_group.id
  ssh_key_id          = var.attach_ssh_key_to_windows ? module.ssh_key.id : null
  subnet_id           = module.subnet.id
  subnet_cidr         = module.subnet.cidr
  security_group_id   = module.security_group.id
  start_ip_offset     = var.ad_start_ip_offset
  use_vni             = var.use_vni
  vni_ids             = module.vni_ad.ids
  user_data           = var.ad_user_data
}

# ── 13. DNS ───────────────────────────────────────────────────────────────────
module "dns" {
  source = "./modules/dns"

  create_dns_instance = var.create_dns_instance
  dns_instance_name   = var.dns_instance_name
  resource_group_id   = module.resource_group.id

  create_dns_zone = var.create_dns_zone
  dns_zone_name   = var.dns_zone_name
  dns_ttl         = var.dns_ttl

  linux_hostnames   = module.vsi_linux.hostnames
  linux_ips         = module.vsi_linux.private_ips
  # Merge jump Windows servers and AD server into a single list for DNS.
  windows_hostnames = concat(module.vsi_windows.hostnames, module.vsi_ad.hostnames)
  windows_ips       = concat(module.vsi_windows.private_ips, module.vsi_ad.private_ips)

  depends_on = [module.vsi_linux, module.vsi_windows, module.vsi_ad]
}
