terraform {
  required_providers {
    netbox = {
      source = "e-breuninger/netbox"
      version = "0.2.2"
    }
    powerdns = {
      source = "ag-TJNII/powerdns"
      version = "101.6.1"
    }
  }
}


//
// VARIABLES
//
variable "env" {}

variable "site_rg" { default = "RG1" }
variable "site_ams" { default = "AMS1" }
variable "site_ldn" { default = "LDN1" }

variable "project" { default = "openlabs"}

variable "service_controller" { default = "endpoint" }
variable "service_mgmt" { default = "mgmt"}
variable "service_network" { default = "net"}
variable "service_storage" { default = "storage"}
variable "service_compute" { default = "compute"}

variable "netbox_cluster" { default = "demo-lab" }
variable "netbox_vm_interface_0" { default = "eth0" }

variable "dns_domain" { default = "cloud.vspace307.io" }

variable "vm_rg_mgmt" { default = "shell"}
variable "vm_rg_controller" { default = "api" }

variable "vm_ams_net_gw0" { default = "ams0" }
variable "vm_ams_net_gw1" { default = "ams1" }
variable "vm_ams_sd_rack5" { default = "sd-rack-5" }
variable "vm_ams_sd_rack6" { default = "sd-rack-6" }
variable "vm_ams_compute_kvm0" { default = "kvm0" }
variable "vm_ams_compute_kvm1" { default = "kvm1" }
variable "vm_ams_compute_kvm2" { default = "kvm2" }

variable "vm_ldn_net_gw0" { default = "ldn0" }
variable "vm_ldn_net_gw1" { default = "ldn1" }
variable "vm_ldn_sd_rack17" { default = "sd-rack-17" }
variable "vm_ldn_sd_rack18" { default = "sd-rack-18" }
variable "vm_ldn_compute_kvm3" { default = "kvm3" }
variable "vm_ldn_compute_kvm4" { default = "kvm4" }
variable "vm_ldn_compute_kvm5" { default = "kvm5" }

variable "subnet_rg_cloud_mgmt" { default = "172.21.55.0/24" }
variable "subnet_ams_cloud_mgmt" { default = "172.22.55.0/24" }
variable "subnet_ldn_cloud_mgmt" { default = "172.23.55.0/24" }
variable "subnet_ams_cloud_gw_ext" { default = "172.22.15.0/24" }
variable "subnet_ldn_cloud_gw_ext" { default = "172.23.15.0/24" }

variable "storage_backend_name_ams_rack_5" { default = "ams-ssd-rack-5" }
variable "storage_backend_name_ams_rack_6" { default = "ams-ssd-rack-6" }
variable "storage_backend_name_ldn_rack_17" { default = "ldn-ssd-rack-17" }
variable "storage_backend_name_ldn_rack_18" { default = "ldn-ssd-rack-18" }

//
// NBX & DNS
//

// RG
// vm-rg-controller
module "nbx_vm_rg_controller" {
  source = "github.com/di-starss/vspace307-cloud-netbox"

  env = var.env
  project = var.project
  service = var.service_controller
  site = var.site_rg
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_rg_controller
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_rg_cloud_mgmt
}

module "dns_vm_rg_controller" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_rg_controller.dns_zone
  record = module.nbx_vm_rg_controller.dns_record
  ip = module.nbx_vm_rg_controller.vm_ip
}

resource "consul_key_prefix" "kv_vm_rg_controller" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_rg_controller.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_rg_controller.vm_fqdn
    "vm_ip" = module.nbx_vm_rg_controller.vm_ip
    "vm_hostname" = module.nbx_vm_rg_controller.vm_hostname
  }
}

// vm-rg-mgmt
module "nbx_vm_rg_mgmt" {
  source = "github.com/di-starss/vspace307-cloud-netbox"
  depends_on = [module.nbx_vm_rg_controller]

  env = var.env
  project = var.project
  service = var.service_mgmt
  site = var.site_rg
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_rg_mgmt
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_rg_cloud_mgmt
}

module "dns_vm_rg_mgmt" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_rg_mgmt.dns_zone
  record = module.nbx_vm_rg_mgmt.dns_record
  ip = module.nbx_vm_rg_mgmt.vm_ip
}

resource "consul_key_prefix" "kv_vm_rg_mgmt" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_rg_mgmt.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_rg_mgmt.vm_fqdn
    "vm_ip" = module.nbx_vm_rg_mgmt.vm_ip
    "vm_hostname" = module.nbx_vm_rg_mgmt.vm_hostname
  }
}


// AMS
// vm-ams-compute-kvm0
module "nbx_vm_ams_compute_kvm0" {
  source = "github.com/di-starss/vspace307-cloud-netbox"

  env = var.env
  project = var.project
  service = var.service_compute
  site = var.site_ams
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_ams_compute_kvm0
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_ams_cloud_mgmt
}

module "dns_vm_ams_compute_kvm0" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_ams_compute_kvm0.dns_zone
  record = module.nbx_vm_ams_compute_kvm0.dns_record
  ip = module.nbx_vm_ams_compute_kvm0.vm_ip
}

resource "consul_key_prefix" "kv_vm_ams_compute_kvm0" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_ams_compute_kvm0.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_ams_compute_kvm0.vm_fqdn
    "vm_ip" = module.nbx_vm_ams_compute_kvm0.vm_ip
    "vm_hostname" = module.nbx_vm_ams_compute_kvm0.vm_hostname
  }
}

// vm-ams-compute-kvm1
module "nbx_vm_ams_compute_kvm1" {
  source = "github.com/di-starss/vspace307-cloud-netbox"
  depends_on = [module.nbx_vm_ams_compute_kvm0]

  env = var.env
  project = var.project
  service = var.service_compute
  site = var.site_ams
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_ams_compute_kvm1
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_ams_cloud_mgmt
}

module "dns_vm_ams_compute_kvm1" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_ams_compute_kvm1.dns_zone
  record = module.nbx_vm_ams_compute_kvm1.dns_record
  ip = module.nbx_vm_ams_compute_kvm1.vm_ip
}

resource "consul_key_prefix" "kv_vm_ams_compute_kvm1" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_ams_compute_kvm1.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_ams_compute_kvm1.vm_fqdn
    "vm_ip" = module.nbx_vm_ams_compute_kvm1.vm_ip
    "vm_hostname" = module.nbx_vm_ams_compute_kvm1.vm_hostname
  }
}

// vm-ams-compute-kvm2
module "nbx_vm_ams_compute_kvm2" {
  source = "github.com/di-starss/vspace307-cloud-netbox"
  depends_on = [
    module.nbx_vm_ams_compute_kvm0,
    module.nbx_vm_ams_compute_kvm1
  ]

  env = var.env
  project = var.project
  service = var.service_compute
  site = var.site_ams
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_ams_compute_kvm2
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_ams_cloud_mgmt
}

module "dns_vm_ams_compute_kvm2" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_ams_compute_kvm2.dns_zone
  record = module.nbx_vm_ams_compute_kvm2.dns_record
  ip = module.nbx_vm_ams_compute_kvm2.vm_ip
}

resource "consul_key_prefix" "kv_vm_ams_compute_kvm2" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_ams_compute_kvm2.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_ams_compute_kvm2.vm_fqdn
    "vm_ip" = module.nbx_vm_ams_compute_kvm2.vm_ip
    "vm_hostname" = module.nbx_vm_ams_compute_kvm2.vm_hostname
  }
}

// vm-ams-sd-rack-5
module "nbx_vm_ams_sd_rack_5" {
  source = "github.com/di-starss/vspace307-cloud-netbox"
  depends_on = [
    module.nbx_vm_ams_compute_kvm0,
    module.nbx_vm_ams_compute_kvm1,
    module.nbx_vm_ams_compute_kvm2
  ]

  env = var.env
  project = var.project
  service = var.service_storage
  site = var.site_ams
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_ams_sd_rack5
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_ams_cloud_mgmt
}

module "dns_vm_ams_sd_rack_5" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_ams_sd_rack_5.dns_zone
  record = module.nbx_vm_ams_sd_rack_5.dns_record
  ip = module.nbx_vm_ams_sd_rack_5.vm_ip
}

resource "consul_key_prefix" "kv_vm_ams_sd_rack_5" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_ams_sd_rack_5.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_ams_sd_rack_5.vm_fqdn
    "vm_ip" = module.nbx_vm_ams_sd_rack_5.vm_ip
    "vm_hostname" = module.nbx_vm_ams_sd_rack_5.vm_hostname
  }
}

// vm-ams-sd-rack-6
module "nbx_vm_ams_sd_rack_6" {
  source = "github.com/di-starss/vspace307-cloud-netbox"
  depends_on = [
    module.nbx_vm_ams_compute_kvm0,
    module.nbx_vm_ams_compute_kvm1,
    module.nbx_vm_ams_compute_kvm2,
    module.nbx_vm_ams_sd_rack_5
  ]

  env = var.env
  project = var.project
  service = var.service_storage
  site = var.site_ams
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_ams_sd_rack6
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_ams_cloud_mgmt
}

module "dns_vm_ams_sd_rack_6" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_ams_sd_rack_6.dns_zone
  record = module.nbx_vm_ams_sd_rack_6.dns_record
  ip = module.nbx_vm_ams_sd_rack_6.vm_ip
}

resource "consul_key_prefix" "kv_vm_ams_sd_rack_6" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_ams_sd_rack_6.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_ams_sd_rack_6.vm_fqdn
    "vm_ip" = module.nbx_vm_ams_sd_rack_6.vm_ip
    "vm_hostname" = module.nbx_vm_ams_sd_rack_6.vm_hostname
  }
}

// vm-ams-net-gw0
module "nbx_vm_ams_net_gw0" {
  source = "github.com/di-starss/vspace307-cloud-netbox"
  depends_on = [
    module.nbx_vm_ams_compute_kvm0,
    module.nbx_vm_ams_compute_kvm1,
    module.nbx_vm_ams_compute_kvm2,
    module.nbx_vm_ams_sd_rack_5,
    module.nbx_vm_ams_sd_rack_6
  ]

  env = var.env
  project = var.project
  service = var.service_network
  site = var.site_ams
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_ams_net_gw0
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_ams_cloud_mgmt
}

module "dns_vm_ams_net_gw0" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_ams_net_gw0.dns_zone
  record = module.nbx_vm_ams_net_gw0.dns_record
  ip = module.nbx_vm_ams_net_gw0.vm_ip
}

resource "consul_key_prefix" "kv_vm_ams_net_gw0" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_ams_net_gw0.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_ams_net_gw0.vm_fqdn
    "vm_ip" = module.nbx_vm_ams_net_gw0.vm_ip
    "vm_hostname" = module.nbx_vm_ams_net_gw0.vm_hostname
  }
}

// vm-ams-net-gw1
module "nbx_vm_ams_net_gw1" {
  source = "github.com/di-starss/vspace307-cloud-netbox"
  depends_on = [
    module.nbx_vm_ams_compute_kvm0,
    module.nbx_vm_ams_compute_kvm1,
    module.nbx_vm_ams_compute_kvm2,
    module.nbx_vm_ams_sd_rack_5,
    module.nbx_vm_ams_sd_rack_6,
    module.nbx_vm_ams_net_gw0
  ]

  env = var.env
  project = var.project
  service = var.service_network
  site = var.site_ams
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_ams_net_gw1
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_ams_cloud_mgmt
}

module "dns_vm_ams_net_gw1" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_ams_net_gw1.dns_zone
  record = module.nbx_vm_ams_net_gw1.dns_record
  ip = module.nbx_vm_ams_net_gw1.vm_ip
}

resource "consul_key_prefix" "kv_vm_ams_net_gw1" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_ams_net_gw1.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_ams_net_gw1.vm_fqdn
    "vm_ip" = module.nbx_vm_ams_net_gw1.vm_ip
    "vm_hostname" = module.nbx_vm_ams_net_gw1.vm_hostname
  }
}

// LDN
// vm-ldn-compute-kvm3
module "nbx_vm_ldn_compute_kvm3" {
  source = "github.com/di-starss/vspace307-cloud-netbox"

  env = var.env
  project = var.project
  service = var.service_compute
  site = var.site_ldn
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_ldn_compute_kvm3
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_ldn_cloud_mgmt
}

module "dns_vm_ldn_compute_kvm3" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_ldn_compute_kvm3.dns_zone
  record = module.nbx_vm_ldn_compute_kvm3.dns_record
  ip = module.nbx_vm_ldn_compute_kvm3.vm_ip
}

resource "consul_key_prefix" "kv_vm_ldn_compute_kvm3" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_ldn_compute_kvm3.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_ldn_compute_kvm3.vm_fqdn
    "vm_ip" = module.nbx_vm_ldn_compute_kvm3.vm_ip
    "vm_hostname" = module.nbx_vm_ldn_compute_kvm3.vm_hostname
  }
}

// vm-ldn-compute-kvm4
module "nbx_vm_ldn_compute_kvm4" {
  source = "github.com/di-starss/vspace307-cloud-netbox"
  depends_on = [ module.dns_vm_ldn_compute_kvm3]

  env = var.env
  project = var.project
  service = var.service_compute
  site = var.site_ldn
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_ldn_compute_kvm4
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_ldn_cloud_mgmt
}

module "dns_vm_ldn_compute_kvm4" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_ldn_compute_kvm4.dns_zone
  record = module.nbx_vm_ldn_compute_kvm4.dns_record
  ip = module.nbx_vm_ldn_compute_kvm4.vm_ip
}

resource "consul_key_prefix" "kv_vm_ldn_compute_kvm4" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_ldn_compute_kvm4.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_ldn_compute_kvm4.vm_fqdn
    "vm_ip" = module.nbx_vm_ldn_compute_kvm4.vm_ip
    "vm_hostname" = module.nbx_vm_ldn_compute_kvm4.vm_hostname
  }
}

// vm-ldn-compute-kvm5
module "nbx_vm_ldn_compute_kvm5" {
  source = "github.com/di-starss/vspace307-cloud-netbox"
  depends_on = [
    module.dns_vm_ldn_compute_kvm3,
    module.nbx_vm_ldn_compute_kvm4
  ]

  env = var.env
  project = var.project
  service = var.service_compute
  site = var.site_ldn
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_ldn_compute_kvm5
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_ldn_cloud_mgmt
}

module "dns_vm_ldn_compute_kvm5" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_ldn_compute_kvm5.dns_zone
  record = module.nbx_vm_ldn_compute_kvm5.dns_record
  ip = module.nbx_vm_ldn_compute_kvm5.vm_ip
}

resource "consul_key_prefix" "kv_vm_ldn_compute_kvm5" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_ldn_compute_kvm5.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_ldn_compute_kvm5.vm_fqdn
    "vm_ip" = module.nbx_vm_ldn_compute_kvm5.vm_ip
    "vm_hostname" = module.nbx_vm_ldn_compute_kvm5.vm_hostname
  }
}

// vm-ldn-sd-rack-17
module "nbx_vm_ldn_sd_rack_17" {
  source = "github.com/di-starss/vspace307-cloud-netbox"
  depends_on = [
    module.dns_vm_ldn_compute_kvm3,
    module.nbx_vm_ldn_compute_kvm4,
    module.nbx_vm_ldn_compute_kvm5
  ]

  env = var.env
  project = var.project
  service = var.service_storage
  site = var.site_ldn
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_ldn_sd_rack17
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_ldn_cloud_mgmt
}

module "dns_vm_ldn_sd_rack_17" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_ldn_sd_rack_17.dns_zone
  record = module.nbx_vm_ldn_sd_rack_17.dns_record
  ip = module.nbx_vm_ldn_sd_rack_17.vm_ip
}

resource "consul_key_prefix" "kv_vm_ldn_sd_rack_17" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_ldn_sd_rack_17.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_ldn_sd_rack_17.vm_fqdn
    "vm_ip" = module.nbx_vm_ldn_sd_rack_17.vm_ip
    "vm_hostname" = module.nbx_vm_ldn_sd_rack_17.vm_hostname
  }
}

// vm-ldn-sd-rack-18
module "nbx_vm_ldn_sd_rack_18" {
  source = "github.com/di-starss/vspace307-cloud-netbox"
  depends_on = [
    module.dns_vm_ldn_compute_kvm3,
    module.nbx_vm_ldn_compute_kvm4,
    module.nbx_vm_ldn_compute_kvm5,
    module.nbx_vm_ldn_sd_rack_17
  ]

  env = var.env
  project = var.project
  service = var.service_storage
  site = var.site_ldn
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_ldn_sd_rack18
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_ldn_cloud_mgmt
}

module "dns_vm_ldn_sd_rack_18" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_ldn_sd_rack_18.dns_zone
  record = module.nbx_vm_ldn_sd_rack_18.dns_record
  ip = module.nbx_vm_ldn_sd_rack_18.vm_ip
}

resource "consul_key_prefix" "kv_vm_ldn_sd_rack_18" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_ldn_sd_rack_18.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_ldn_sd_rack_18.vm_fqdn
    "vm_ip" = module.nbx_vm_ldn_sd_rack_18.vm_ip
    "vm_hostname" = module.nbx_vm_ldn_sd_rack_18.vm_hostname
  }
}

// vm-ldn-net-gw0
module "nbx_vm_ldn_net_gw0" {
  source = "github.com/di-starss/vspace307-cloud-netbox"
  depends_on = [
    module.dns_vm_ldn_compute_kvm3,
    module.nbx_vm_ldn_compute_kvm4,
    module.nbx_vm_ldn_compute_kvm5,
    module.nbx_vm_ldn_sd_rack_17,
    module.nbx_vm_ldn_sd_rack_18
  ]

  env = var.env
  project = var.project
  service = var.service_network
  site = var.site_ldn
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_ldn_net_gw0
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_ldn_cloud_mgmt
}

module "dns_vm_ldn_net_gw0" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_ldn_net_gw0.dns_zone
  record = module.nbx_vm_ldn_net_gw0.dns_record
  ip = module.nbx_vm_ldn_net_gw0.vm_ip
}

resource "consul_key_prefix" "kv_vm_ldn_net_gw0" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_ldn_net_gw0.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_ldn_net_gw0.vm_fqdn
    "vm_ip" = module.nbx_vm_ldn_net_gw0.vm_ip
    "vm_hostname" = module.nbx_vm_ldn_net_gw0.vm_hostname
  }
}

// vm-ldn-net-gw1
module "nbx_vm_ldn_net_gw1" {
  source = "github.com/di-starss/vspace307-cloud-netbox"
  depends_on = [
    module.dns_vm_ldn_compute_kvm3,
    module.nbx_vm_ldn_compute_kvm4,
    module.nbx_vm_ldn_compute_kvm5,
    module.nbx_vm_ldn_sd_rack_17,
    module.nbx_vm_ldn_sd_rack_18,
    module.nbx_vm_ldn_net_gw0
  ]

  env = var.env
  project = var.project
  service = var.service_network
  site = var.site_ldn
  domain = var.dns_domain

  cluster = var.netbox_cluster
  vm_name = var.vm_ldn_net_gw1
  vm_interface = var.netbox_vm_interface_0
  prefix = var.subnet_ldn_cloud_mgmt
}

module "dns_vm_ldn_net_gw1" {
  source = "github.com/di-starss/vspace307-cloud-dns-record"

  zone = module.nbx_vm_ldn_net_gw1.dns_zone
  record = module.nbx_vm_ldn_net_gw1.dns_record
  ip = module.nbx_vm_ldn_net_gw1.vm_ip
}

resource "consul_key_prefix" "kv_vm_ldn_net_gw1" {
  path_prefix = "${var.project}/${var.env}/vm/${module.nbx_vm_ldn_net_gw1.vm_hostname}/"

  subkeys = {
    "vm_fqdn" = module.nbx_vm_ldn_net_gw1.vm_fqdn
    "vm_ip" = module.nbx_vm_ldn_net_gw1.vm_ip
    "vm_hostname" = module.nbx_vm_ldn_net_gw1.vm_hostname
  }
}


//
// KV/NET/{VM}/AZ
//
resource "consul_key_prefix" "net_ams_gw0" {
  path_prefix = "${var.project}/${var.env}/net/${module.nbx_vm_ams_net_gw0.vm_hostname}/"
  subkeys = {
    "az" = var.site_ams
  }
}

resource "consul_key_prefix" "net_ams_gw1" {
  path_prefix = "${var.project}/${var.env}/net/${module.nbx_vm_ams_net_gw1.vm_hostname}/"
  subkeys = {
    "az" = var.site_ams
  }
}

resource "consul_key_prefix" "net_ldn_gw0" {
  path_prefix = "${var.project}/${var.env}/net/${module.nbx_vm_ldn_net_gw0.vm_hostname}/"
  subkeys = {
    "az" = var.site_ldn
  }
}

resource "consul_key_prefix" "net_ldn_gw1" {
  path_prefix = "${var.project}/${var.env}/net/${module.nbx_vm_ldn_net_gw1.vm_hostname}/"
  subkeys = {
    "az" = var.site_ldn
  }
}


//
// KV/STORAGE/{VM}/BACKEND_NAME
//
resource "consul_key_prefix" "sd_ams_sd_rack_5" {
  path_prefix = "${var.project}/${var.env}/storage/${module.nbx_vm_ams_sd_rack_5.vm_hostname}/"
  subkeys = {
    "backend_name" = var.storage_backend_name_ams_rack_5
  }
}

resource "consul_key_prefix" "sd_ams_sd_rack_6" {
  path_prefix = "${var.project}/${var.env}/storage/${module.nbx_vm_ams_sd_rack_6.vm_hostname}/"
  subkeys = {
    "backend_name" = var.storage_backend_name_ams_rack_6
  }
}

resource "consul_key_prefix" "sd_ldn_sd_rack_17" {
  path_prefix = "${var.project}/${var.env}/storage/${module.nbx_vm_ldn_sd_rack_17.vm_hostname}/"
  subkeys = {
    "backend_name" = var.storage_backend_name_ldn_rack_17
  }
}

resource "consul_key_prefix" "sd_ldn_sd_rack_18" {
  path_prefix = "${var.project}/${var.env}/storage/${module.nbx_vm_ldn_sd_rack_18.vm_hostname}/"
  subkeys = {
    "backend_name" = var.storage_backend_name_ldn_rack_18
  }
}


//
// OUTPUT
//

// site
output "env" { value = var.env }

output "site_rg" { value = var.site_rg }
output "site_ams" { value = var.site_ams }
output "site_ldn" { value = var.site_ldn }

// project
output "project" { value = var.project }

// service
output "service_controller" { value = var.service_controller  }
output "service_mgmt" { value = var.service_mgmt }
output "service_network" { value = var.service_network }
output "service_storage" { value = var.service_storage }
output "service_compute" { value = var.service_compute }

// storage_backend_name
output "storage_backend_name_ams_rack_5" { value = var.storage_backend_name_ams_rack_5 }
output "storage_backend_name_ams_rack_6" { value = var.storage_backend_name_ams_rack_6 }
output "storage_backend_name_ldn_rack_17" { value = var.storage_backend_name_ldn_rack_17 }
output "storage_backend_name_ldn_rack_18" { value = var.storage_backend_name_ldn_rack_18 }

// subnet
output "subnet_rg_cloud_mgmt" { value = var.subnet_rg_cloud_mgmt }
output "subnet_ams_cloud_mgmt" { value = var.subnet_ams_cloud_mgmt }
output "subnet_ldn_cloud_mgmt" { value = var.subnet_ldn_cloud_mgmt }

// nbx_vm_rg_controller
output "vm_rg_controller_name" { value = module.nbx_vm_rg_controller.vm_name }
output "vm_rg_controller_fqdn" { value = module.nbx_vm_rg_controller.vm_fqdn }
output "vm_rg_controller_hostname" { value = module.nbx_vm_rg_controller.vm_hostname }
output "vm_rg_controller_ip" { value = module.nbx_vm_rg_controller.vm_ip }

// nbx_vm_rg_mgmt
output "vm_rg_mgmt_name" { value = module.nbx_vm_rg_mgmt.vm_name }
output "vm_rg_mgmt_fqdn" { value = module.nbx_vm_rg_mgmt.vm_fqdn }
output "vm_rg_mgmt_hostname" { value = module.nbx_vm_rg_mgmt.vm_hostname }
output "vm_rg_mgmt_ip" { value = module.nbx_vm_rg_mgmt.vm_ip }

// nbx_vm_ams_compute_kvm0
output "vm_ams_compute_kvm0_name" { value = module.nbx_vm_ams_compute_kvm0.vm_name }
output "vm_ams_compute_kvm0_fqdn" { value = module.nbx_vm_ams_compute_kvm0.vm_fqdn }
output "vm_ams_compute_kvm0_hostname" { value = module.nbx_vm_ams_compute_kvm0.vm_hostname }
output "vm_ams_compute_kvm0_ip" { value = module.nbx_vm_ams_compute_kvm0.vm_ip }

// nbx_vm_ams_compute_kvm1
output "vm_ams_compute_kvm1_name" { value = module.nbx_vm_ams_compute_kvm1.vm_name }
output "vm_ams_compute_kvm1_fqdn" { value = module.nbx_vm_ams_compute_kvm1.vm_fqdn }
output "vm_ams_compute_kvm1_hostname" { value = module.nbx_vm_ams_compute_kvm1.vm_hostname }
output "vm_ams_compute_kvm1_ip" { value = module.nbx_vm_ams_compute_kvm1.vm_ip }

// nbx_vm_ams_compute_kvm2
output "vm_ams_compute_kvm2_name" { value = module.nbx_vm_ams_compute_kvm2.vm_name }
output "vm_ams_compute_kvm2_fqdn" { value = module.nbx_vm_ams_compute_kvm2.vm_fqdn }
output "vm_ams_compute_kvm2_hostname" { value = module.nbx_vm_ams_compute_kvm2.vm_hostname }
output "vm_ams_compute_kvm2_ip" { value = module.nbx_vm_ams_compute_kvm2.vm_ip }

// nbx_vm_ldn_compute_kvm3
output "vm_ldn_compute_kvm3_name" { value = module.nbx_vm_ldn_compute_kvm3.vm_name }
output "vm_ldn_compute_kvm3_fqdn" { value = module.nbx_vm_ldn_compute_kvm3.vm_fqdn }
output "vm_ldn_compute_kvm3_hostname" { value = module.nbx_vm_ldn_compute_kvm3.vm_hostname }
output "vm_ldn_compute_kvm3_ip" { value = module.nbx_vm_ldn_compute_kvm3.vm_ip }

// nbx_vm_ldn_compute_kvm4
output "vm_ldn_compute_kvm4_name" { value = module.nbx_vm_ldn_compute_kvm4.vm_name }
output "vm_ldn_compute_kvm4_fqdn" { value = module.nbx_vm_ldn_compute_kvm4.vm_fqdn }
output "vm_ldn_compute_kvm4_hostname" { value = module.nbx_vm_ldn_compute_kvm4.vm_hostname }
output "vm_ldn_compute_kvm4_ip" { value = module.nbx_vm_ldn_compute_kvm4.vm_ip }

// nbx_vm_ldn_compute_kvm5
output "vm_ldn_compute_kvm5_name" { value = module.nbx_vm_ldn_compute_kvm5.vm_name }
output "vm_ldn_compute_kvm5_fqdn" { value = module.nbx_vm_ldn_compute_kvm5.vm_fqdn }
output "vm_ldn_compute_kvm5_hostname" { value = module.nbx_vm_ldn_compute_kvm5.vm_hostname }
output "vm_ldn_compute_kvm5_ip" { value = module.nbx_vm_ldn_compute_kvm5.vm_ip }

// nbx_vm_ams_sd_rack_5
output "vm_ams_sd_rack_5_name" { value = module.nbx_vm_ams_sd_rack_5.vm_name }
output "vm_ams_sd_rack_5_fqdn" { value = module.nbx_vm_ams_sd_rack_5.vm_fqdn }
output "vm_ams_sd_rack_5_hostname" { value = module.nbx_vm_ams_sd_rack_5.vm_hostname }
output "vm_ams_sd_rack_5_ip" { value = module.nbx_vm_ams_sd_rack_5.vm_ip }

// nbx_vm_ams_sd_rack_6
output "vm_ams_sd_rack_6_name" { value = module.nbx_vm_ams_sd_rack_6.vm_name }
output "vm_ams_sd_rack_6_fqdn" { value = module.nbx_vm_ams_sd_rack_6.vm_fqdn }
output "vm_ams_sd_rack_6_hostname" { value = module.nbx_vm_ams_sd_rack_6.vm_hostname }
output "vm_ams_sd_rack_6_ip" { value = module.nbx_vm_ams_sd_rack_6.vm_ip }

// nbx_vm_ldn_sd_rack_17
output "vm_ldn_sd_rack_17_name" { value = module.nbx_vm_ldn_sd_rack_17.vm_name }
output "vm_ldn_sd_rack_17_fqdn" { value = module.nbx_vm_ldn_sd_rack_17.vm_fqdn }
output "vm_ldn_sd_rack_17_hostname" { value = module.nbx_vm_ldn_sd_rack_17.vm_hostname }
output "vm_ldn_sd_rack_17_ip" { value = module.nbx_vm_ldn_sd_rack_17.vm_ip }

// nbx_vm_ldn_sd_rack_18
output "vm_ldn_sd_rack_18_name" { value = module.nbx_vm_ldn_sd_rack_18.vm_name }
output "vm_ldn_sd_rack_18_fqdn" { value = module.nbx_vm_ldn_sd_rack_18.vm_fqdn }
output "vm_ldn_sd_rack_18_hostname" { value = module.nbx_vm_ldn_sd_rack_18.vm_hostname }
output "vm_ldn_sd_rack_18_ip" { value = module.nbx_vm_ldn_sd_rack_18.vm_ip }

// nbx_vm_ams_net_gw0
output "vm_ams_net_gw0_name" { value = module.nbx_vm_ams_net_gw0.vm_name }
output "vm_ams_net_gw0_fqdn" { value = module.nbx_vm_ams_net_gw0.vm_fqdn }
output "vm_ams_net_gw0_hostname" { value = module.nbx_vm_ams_net_gw0.vm_hostname }
output "vm_ams_net_gw0_ip" { value = module.nbx_vm_ams_net_gw0.vm_ip }

// nbx_vm_ams_net_gw1
output "vm_ams_net_gw1_name" { value = module.nbx_vm_ams_net_gw1.vm_name }
output "vm_ams_net_gw1_fqdn" { value = module.nbx_vm_ams_net_gw1.vm_fqdn }
output "vm_ams_net_gw1_hostname" { value = module.nbx_vm_ams_net_gw1.vm_hostname }
output "vm_ams_net_gw1_ip" { value = module.nbx_vm_ams_net_gw1.vm_ip }

// nbx_vm_ldn_net_gw0
output "vm_ldn_net_gw0_name" { value = module.nbx_vm_ldn_net_gw0.vm_name }
output "vm_ldn_net_gw0_fqdn" { value = module.nbx_vm_ldn_net_gw0.vm_fqdn }
output "vm_ldn_net_gw0_hostname" { value = module.nbx_vm_ldn_net_gw0.vm_hostname }
output "vm_ldn_net_gw0_ip" { value = module.nbx_vm_ldn_net_gw0.vm_ip }

// nbx_vm_ldn_net_gw1
output "vm_ldn_net_gw1_name" { value = module.nbx_vm_ldn_net_gw1.vm_name }
output "vm_ldn_net_gw1_fqdn" { value = module.nbx_vm_ldn_net_gw1.vm_fqdn }
output "vm_ldn_net_gw1_hostname" { value = module.nbx_vm_ldn_net_gw1.vm_hostname }
output "vm_ldn_net_gw1_ip" { value = module.nbx_vm_ldn_net_gw1.vm_ip }
