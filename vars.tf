variable "name" {
  description = "The name of the libvirt domain (virtual machine) and related resources."
  type        = string
}

variable "description" {
  description = "Description for the libvirt domain (virtual machine)."
  type        = string
  default     = ""
}

variable "vcpu" {
  description = "Number of virtual CPUs to assign to the domain."
  type        = number
  default     = 1
}

variable "memory" {
  description = "Amount of memory (in MB) to assign to the domain."
  type        = number
  default     = 2048
}

variable "storage_pool" {
  description = "Name of the libvirt storage pool where volumes will be created."
  type        = string
  default     = "default"
}

variable "boot_image_url" {
  description = "URL for the base QCOW2 image used as the boot disk."
  type        = string
  default     = "https://download.fedoraproject.org/pub/fedora/linux/releases/43/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2"
}

variable "boot_disk_size" {
  description = "Boot disk virtual size in bytes. Null means use the source image's natural size."
  type        = number
  default     = null
}

variable "extra_volumes" {
  description = <<EOF
List of additional volumes to attach to the domain. Each object should contain:
  - name: Name of the volume.
  - size: Size of the volume in bytes.
Example:
[
  {
    name = "runner-var-lib-docker.qcow2"
    size = 107374182400
  }
]
EOF
  type = list(object({
    name = string
    size = number
  }))
  default = []
}

variable "bridge_name" {
  description = "Name of the network bridge for the second network interface."
  type        = string
  default     = "nm-bridge"
}

variable "cloudinit_meta_data_template" {
  description = "The template content for cloud-init meta-data configuration."
  type        = string
}

variable "cloudinit_meta_data_vars" {
  description = "Variable map for the cloud-init meta-data template."
  type        = map(string)
}

variable "cloudinit_user_data_template" {
  description = "The template content for cloud-init user-data configuration."
  type        = string
}

variable "cloudinit_user_data_vars" {
  description = "Variable map for the cloud-init user-data template. Set to {} if not used."
  type        = map(string)
}

variable "cloudinit_network_config_template" {
  description = "The template content for cloud-init network configuration."
  type        = string
}

variable "cloudinit_network_config_vars" {
  description = "Variable map for the cloud-init network configuration template."
  type        = map(string)
}
