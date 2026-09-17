###############################################################################
# terraform.tfvars — Example values matching the HPC pilot scenario
#
# Copy this file and adjust values for your environment.
# Never commit your ibmcloud_api_key to source control — use an environment
# variable instead:
#   export TF_VAR_ibmcloud_api_key="<your_key>"
###############################################################################

# ── GLOBAL ────────────────────────────────────────────────────────────────────
region = "us-south"
zone   = "us-south-1"
tags   = ["env:hpc-pilot", "managed-by:terraform"]

# ── RESOURCE GROUP ────────────────────────────────────────────────────────────
# Use an existing resource group — Terraform will look it up by name.
create_resource_group = false
resource_group_name   = "HPC-Common"

# ── VPC ───────────────────────────────────────────────────────────────────────
# Use an existing VPC — Terraform will look it up by name.
create_vpc = false
vpc_name   = "HPC-VPC"

# ── ADDRESS PREFIX ────────────────────────────────────────────────────────────
# Use an existing address prefix — Terraform will look it up by name.
create_address_prefix = false
address_prefix_name   = "hpc-prefix-01"

# ── SUBNET ────────────────────────────────────────────────────────────────────
# Use an existing subnet — Terraform will look it up by name.
create_subnet = false
subnet_name   = "management-subnet"

# ── SECURITY GROUP ────────────────────────────────────────────────────────────
# Use an existing security group — Terraform will look it up by name.
create_security_group = false
security_group_name   = "management-sg"

# ── SSH KEY ───────────────────────────────────────────────────────────────────
# Use an existing SSH key — must be RSA because it is also used on Windows.
create_ssh_key            = false
ssh_key_name              = "hpc-admin-key"
ssh_key_type              = "rsa"
attach_ssh_key_to_windows = true

# ── VNI ───────────────────────────────────────────────────────────────────────
# Use traditional primary_network_interface (set true to use VNIs instead).
use_vni = false

# ── LINUX JUMP SERVERS ────────────────────────────────────────────────────────
# Replace linux_image_id with the actual IBM Cloud image ID for your region.
# To list available images: ibmcloud is images --visibility public
number_of_jump_servers = 2
linux_hostname_prefix  = "jump"
linux_image_id         = "r006-REPLACE-WITH-LINUX-IMAGE-ID"
linux_profile          = "bx2-2x8"

# Linux VSIs will receive:
#   10.x.x.4  (offset 4)
#   10.x.x.5  (offset 5)
linux_start_ip_offset = 4

# ── WINDOWS SERVERS ───────────────────────────────────────────────────────────
# Replace windows_image_id with the actual IBM Cloud Windows image ID.
number_of_windows_servers = 2
windows_hostname_prefix   = "win"
windows_image_id          = "r006-REPLACE-WITH-WINDOWS-IMAGE-ID"
windows_profile           = "bx2-4x16"

# Windows VSIs will receive:
#   10.x.x.10 (offset 10)
#   10.x.x.11 (offset 11)
windows_start_ip_offset = 10

# Optional: PowerShell user_data to enable WinRM on first boot.
# windows_user_data = <<-PS1
#   <powershell>
#   Enable-PSRemoting -Force
#   </powershell>
# PS1

# ── DNS ───────────────────────────────────────────────────────────────────────
# Use an existing DNS Services instance and zone.
create_dns_instance = false
dns_instance_name   = "HPC-Private-DNS"

create_dns_zone = false
dns_zone_name   = "hpc.example.internal"

dns_ttl = 300
