# terraform-libvirt-domain

Terraform module for creating libvirt domains (VMs) with cloud-init and optional Ansible Automation Platform integration.

## Usage

```hcl
module "vm" {
  source = "git::https://github.com/makeitworkcloud/terraform-libvirt-domain.git?ref=v1.0.0"

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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_libvirt"></a> [libvirt](#requirement\_libvirt) | >= 0.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aap"></a> [aap](#provider\_aap) | n/a |
| <a name="provider_libvirt"></a> [libvirt](#provider\_libvirt) | >= 0.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| aap_host.host | resource |
| aap_job.job | resource |
| [libvirt_cloudinit_disk.commoninit](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/cloudinit_disk) | resource |
| [libvirt_domain.vm](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/domain) | resource |
| [libvirt_volume.boot](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume) | resource |
| [libvirt_volume.cloudinit](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume) | resource |
| [libvirt_volume.extra](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume) | resource |
| aap_inventory.inventory | data source |
| aap_job_template.job_template | data source |
| aap_organization.org | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aap_inventory_name"></a> [aap\_inventory\_name](#input\_aap\_inventory\_name) | Name of the AAP inventory to use. | `string` | `"libvirt-infra"` | no |
| <a name="input_aap_job_template_name"></a> [aap\_job\_template\_name](#input\_aap\_job\_template\_name) | Name of the AAP job template to run.  If left empty, will default to configure\_<name> | `string` | `""` | no |
| <a name="input_aap_org_name"></a> [aap\_org\_name](#input\_aap\_org\_name) | Name of the Ansible Automation Platform (AAP) organization. | `string` | `"Default"` | no |
| <a name="input_boot_image_url"></a> [boot\_image\_url](#input\_boot\_image\_url) | URL for the base QCOW2 image used as the boot disk. | `string` | `"https://download.fedoraproject.org/pub/fedora/linux/releases/43/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2"` | no |
| <a name="input_bridge_name"></a> [bridge\_name](#input\_bridge\_name) | Name of the network bridge for the second network interface. | `string` | `"nm-bridge"` | no |
| <a name="input_cloudinit_meta_data_template"></a> [cloudinit\_meta\_data\_template](#input\_cloudinit\_meta\_data\_template) | The template content for cloud-init meta-data configuration. | `string` | n/a | yes |
| <a name="input_cloudinit_meta_data_vars"></a> [cloudinit\_meta\_data\_vars](#input\_cloudinit\_meta\_data\_vars) | Variable map for the cloud-init meta-data template. | `map(string)` | n/a | yes |
| <a name="input_cloudinit_network_config_template"></a> [cloudinit\_network\_config\_template](#input\_cloudinit\_network\_config\_template) | The template content for cloud-init network configuration. | `string` | n/a | yes |
| <a name="input_cloudinit_network_config_vars"></a> [cloudinit\_network\_config\_vars](#input\_cloudinit\_network\_config\_vars) | Variable map for the cloud-init network configuration template. | `map(string)` | n/a | yes |
| <a name="input_cloudinit_user_data_template"></a> [cloudinit\_user\_data\_template](#input\_cloudinit\_user\_data\_template) | The template content for cloud-init user-data configuration. | `string` | n/a | yes |
| <a name="input_cloudinit_user_data_vars"></a> [cloudinit\_user\_data\_vars](#input\_cloudinit\_user\_data\_vars) | Variable map for the cloud-init user-data template. Set to {} if not used. | `map(string)` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description for the libvirt domain (virtual machine). | `string` | `""` | no |
| <a name="input_enable_aap"></a> [enable\_aap](#input\_enable\_aap) | Whether to provision Ansible Automation Platform (AAP) resources for this domain. | `bool` | `false` | no |
| <a name="input_extra_volumes"></a> [extra\_volumes](#input\_extra\_volumes) | List of additional volumes to attach to the domain. Each object should contain:<br/>  - name: Name of the volume.<br/>  - size: Size of the volume in bytes.<br/>Example:<br/>[<br/>  {<br/>    name = "runner-var-lib-docker.qcow2"<br/>    size = 107374182400<br/>  }<br/>] | <pre>list(object({<br/>    name = string<br/>    size = number<br/>  }))</pre> | `[]` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount of memory (in MB) to assign to the domain. | `number` | `2048` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the libvirt domain (virtual machine) and related resources. | `string` | n/a | yes |
| <a name="input_private_ip_addr"></a> [private\_ip\_addr](#input\_private\_ip\_addr) | Private IP address to assign to the VM (used for network config and inventory). | `string` | n/a | yes |
| <a name="input_proxyhost"></a> [proxyhost](#input\_proxyhost) | Proxy host for SSH connection, used in ansible\_ssh\_common\_args. | `string` | n/a | yes |
| <a name="input_storage_pool"></a> [storage\_pool](#input\_storage\_pool) | Name of the libvirt storage pool where volumes will be created. | `string` | `"default"` | no |
| <a name="input_vcpu"></a> [vcpu](#input\_vcpu) | Number of virtual CPUs to assign to the domain. | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_boot_volume_id"></a> [boot\_volume\_id](#output\_boot\_volume\_id) | The ID of the boot volume |
| <a name="output_cloudinit_disk_id"></a> [cloudinit\_disk\_id](#output\_cloudinit\_disk\_id) | The ID of the cloud-init disk |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | The ID of the libvirt domain |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | The name of the libvirt domain |
<!-- END_TF_DOCS -->
