##ESPECIFICA O PROVICER VCENTER UTILIZANDO AS VARIAVEIS PRE DEFINIDAS
provider "vsphere" {
   vsphere_server = "${var.vsphere_server}"
   user = "${var.vsphere_user}"
   password = "${var.vsphere_password}"
   allow_unverified_ssl = true
}
## APONTA O DATACENTER QUE A VM SERA CRIADA
data "vsphere_datacenter" "dc" {
  #name = "DC_DES_CAS"
  name = "${var.vsphere_dc}"
  }
## APONTA O DATASTORE QUE A VM SERA CRIADA
data "vsphere_datastore" "datastore" {
  name          = "${var.datastore_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  }


## APONTA O RESOURCE POOL
data "vsphere_resource_pool" "pool" {
  name          = "Resources"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
 }

## APONTA O PORTGROUP QUE A VM SERA CRIADA
data "vsphere_network" "mgmt_lan" {
  name          = "${var.vlan_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
 }

## APONTA O TEMPLATE UA A VM SERA CRIADA
data "vsphere_virtual_machine" "template" {
  name = "${var.template_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
 }

## FAZ O BUILD DA VM COM AS ESPECIFICAÇÕES DE CONF
resource "vsphere_virtual_machine" "vm" {
  name             = "${var.vm_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  num_cpus   = 2
  memory     = 4096
  wait_for_guest_net_timeout = 0
  guest_id = "rhel6_64Guest"
  nested_hv_enabled =true
  network_interface {
  network_id     = "${data.vsphere_network.mgmt_lan.id}"
  adapter_type   = "vmxnet3"

 }

lifecycle {
  create_before_destroy = true
 }


disk {
   unit_number      = 0
   label             = "disk0"
   size             = 60
   thin_provisioned = false
   eagerly_scrub = true
   }

#disk {
#   unit_number      = 1
#   label             = "disk1"
#   size             = 60
#   thin_provisioned = false
#   }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options{
        host_name = "${var.vm_name}"
        domain = "${var.dns_suffix}"
      }
      network_interface {
        ipv4_address = "${var.ipv4}"
        ipv4_netmask = "${var.mask_id}"
      }

      ipv4_gateway = "${var.ipv4_gateway}"
      dns_suffix_list = ["${var.dns_suffix}"]
      dns_server_list = ["${var.dns_server}","${var.dns_server2}"]
    }
    }
}

