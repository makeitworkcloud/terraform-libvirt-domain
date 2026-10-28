# terraform-libvirt-domain

Terraform module for creating libvirt domains (VMs) with cloud-init and optional Ansible Automation Platform integration.

## Usage

```hcl
module "vm" {
  source = "git::https://github.com/makeitworkcloud/terraform-libvirt-domain.git?ref=v0.1.0"

  name        = "my-vm"
  description = "My virtual machine"
  vcpu        = 2
  memory      = 4096

  cloudinit_meta_data_template      = file("${path.module}/templates/meta-data.tpl")
  cloudinit_meta_data_vars          = { hostname = "my-vm" }
  cloudinit_user_data_template      = file("${path.module}/templates/user-data.tpl")
  cloudinit_user_data_vars          = {}
  cloudinit_network_config_template = file("${path.module}/templates/network-config.tpl")
  cloudinit_network_config_vars     = { ip_address = "192.168.1.100" }

  private_ip_addr = "192.168.1.100"
  proxyhost       = "bastion.example.com"
}
```

## Existing raw disks

`existing_disks` attaches existing raw files on the libvirt host without creating
managed volumes. It defaults to `{}`. This feature requires libvirt provider
`>= 0.9.9, < 0.10` and is not available in the older `v0.1.0` example above.
Until a release containing this feature is published, use a local copy of this
module (replace the relative source path below):

```hcl
module "retained_vm" {
  source = "./path/to/module"

  name                              = "retained-vm"
  cloudinit_meta_data_template      = "${path.module}/templates/meta-data.tpl"
  cloudinit_meta_data_vars          = { hostname = "retained-vm" }
  cloudinit_user_data_template      = "${path.module}/templates/user-data.tpl"
  cloudinit_user_data_vars          = {}
  cloudinit_network_config_template = "${path.module}/templates/network-config.tpl"
  cloudinit_network_config_vars     = { ip_address = "192.168.1.101" }

  existing_disks = {
    vdb = {
      source_file = "/srv/retained/ssd.raw"
      serial      = "k3s-retained-ssd"
    }
    vdc = {
      source_file = "/srv/retained/nvme.raw"
      serial      = "k3s-retained-nvme"
    }
  }
}
```

Targets must be `vdb` through `vdz`; `vda` remains the boot disk.
`extra_volumes` still creates managed volumes and assigns targets sequentially
from `vdb` through `vdj`; existing targets must not overlap those assignments.
Disk order is boot, managed extras, existing disks sorted by target, then the
cloud-init cdrom. Existing disks use `raw`, virtio, and `discard = "unmap"`.
Serials must be unique, 1-20 characters of `[A-Za-z0-9._-]`; use their stable
guest `/dev/disk/by-id/virtio-<serial>` names rather than relying on enumeration.

The operator owns file creation, sizing, permissions/security labels, backups,
and eventual deletion. Files must already exist on the libvirt host, be raw
images (not QCOW2 or block devices), and be accessible to QEMU. This module does
not create, resize, import, format, or delete them, including on domain rebuild
or removal; guest writes still modify their contents. Do not attach the same
writable backing file to multiple VMs. Paths must be absolute, non-root, unique,
and contain no whitespace, repeated/trailing slashes, or `.`/`..` components.
Uniqueness is textual: detecting symlink/hard-link aliases and verifying the
actual file format remain operator responsibilities. Removing a map entry
removes its attachment, not its backing file. Review the domain plan before
changing attachments; no live attachment behavior is guaranteed here.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_libvirt"></a> [libvirt](#requirement\_libvirt) | >= 0.9.9, < 0.10 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_libvirt"></a> [libvirt](#provider\_libvirt) | >= 0.9.9, < 0.10 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [libvirt_cloudinit_disk.commoninit](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/cloudinit_disk) | resource |
| [libvirt_domain.vm](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/domain) | resource |
| [libvirt_volume.boot](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume) | resource |
| [libvirt_volume.cloudinit](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume) | resource |
| [libvirt_volume.extra](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume) | resource |
| [terraform_data.cloudinit_content](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_autostart"></a> [autostart](#input\_autostart) | Whether the domain should start automatically when libvirtd starts. | `bool` | `false` | no |
| <a name="input_boot_disk_size"></a> [boot\_disk\_size](#input\_boot\_disk\_size) | Boot disk virtual size in bytes. Null means use the source image's natural size. | `number` | `null` | no |
| <a name="input_boot_image_url"></a> [boot\_image\_url](#input\_boot\_image\_url) | URL for the base QCOW2 image used as the boot disk. | `string` | `"https://download.fedoraproject.org/pub/fedora/linux/releases/43/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2"` | no |
| <a name="input_boot_rebuild_token"></a> [boot\_rebuild\_token](#input\_boot\_rebuild\_token) | Non-null forces boot-volume and domain replacement. Never remove or change it after a confirmed rebuild. | `string` | `null` | no |
| <a name="input_bridge_name"></a> [bridge\_name](#input\_bridge\_name) | Name of the network bridge for the second network interface. | `string` | `"nm-bridge"` | no |
| <a name="input_cloudinit_meta_data_template"></a> [cloudinit\_meta\_data\_template](#input\_cloudinit\_meta\_data\_template) | The template content for cloud-init meta-data configuration. | `string` | n/a | yes |
| <a name="input_cloudinit_meta_data_vars"></a> [cloudinit\_meta\_data\_vars](#input\_cloudinit\_meta\_data\_vars) | Variable map for the cloud-init meta-data template. | `map(string)` | n/a | yes |
| <a name="input_cloudinit_network_config_template"></a> [cloudinit\_network\_config\_template](#input\_cloudinit\_network\_config\_template) | The template content for cloud-init network configuration. | `string` | n/a | yes |
| <a name="input_cloudinit_network_config_vars"></a> [cloudinit\_network\_config\_vars](#input\_cloudinit\_network\_config\_vars) | Variable map for the cloud-init network configuration template. | `map(string)` | n/a | yes |
| <a name="input_cloudinit_user_data_template"></a> [cloudinit\_user\_data\_template](#input\_cloudinit\_user\_data\_template) | The template content for cloud-init user-data template. | `string` | n/a | yes |
| <a name="input_cloudinit_user_data_vars"></a> [cloudinit\_user\_data\_vars](#input\_cloudinit\_user\_data\_vars) | Variable map for the cloud-init user-data template. Set to {} if not used. | `map(string)` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description for the libvirt domain. | `string` | `""` | no |
| <a name="input_existing_disks"></a> [existing\_disks](#input\_existing\_disks) | Existing raw files to attach by virtio target (vdb-vdz). Each disk requires a unique absolute source_file and a unique 1-20 character serial using [A-Za-z0-9._-]. File lifecycle is external to this module. | <pre>map(object({<br/>    source_file = string<br/>    serial      = string<br/>  }))</pre> | `{}` | no |
| <a name="input_extra_volumes"></a> [extra\_volumes](#input\_extra\_volumes) | List of additional volumes to attach to the domain. Each object should contain:<br/>  - name: Name of the volume.<br/>  - size: Size of the volume in bytes.<br/>Example:<br/>[<br/>  {<br/>    name = "runner-var-lib-docker.qcow2"<br/>    size = 107374182400<br/>  }<br/>] | <pre>list(object({<br/>    name = string<br/>    size = number<br/>  }))</pre> | `[]` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount of memory (in MB) to assign to the domain. | `number` | `2048` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the libvirt domain (virtual machine) and related resources. | `string` | n/a | yes |
| <a name="input_storage_pool"></a> [storage\_pool](#input\_storage\_pool) | Name of the libvirt storage pool where volumes will be created. | `string` | `"default"` | no |
| <a name="input_vcpu"></a> [vcpu](#input\_vcpu) | Number of virtual CPUs to assign to the domain. | `number` | `1` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_boot_volume_id"></a> [boot\_volume\_id](#output\_boot\_volume\_id) | The ID of the boot volume |
| <a name="output_cloudinit_disk_id"></a> [cloudinit\_disk\_id](#output\_cloudinit\_disk\_id) | The ID of the cloud-init disk |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | The ID of the libvirt domain |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | The name of the libvirt domain |
<!-- END_TF_DOCS -->
