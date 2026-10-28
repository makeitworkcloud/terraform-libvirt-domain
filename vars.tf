variable "name" {
  description = "The name of the libvirt domain (virtual machine) and related resources."
  type        = string
}

variable "description" {
  description = "Description for the libvirt domain."
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

variable "boot_rebuild_token" {
  description = "Non-null forces boot-volume and domain replacement. Never remove or change it after a confirmed rebuild."
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.boot_rebuild_token == null || can(regex("^[A-Za-z0-9._-]{1,64}$", var.boot_rebuild_token))
    error_message = "boot_rebuild_token must be null or 1-64 characters of [A-Za-z0-9._-]."
  }
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

variable "existing_disks" {
  description = "Existing raw files to attach by virtio target (vdb-vdz). Each disk requires a unique absolute source_file and a unique 1-20 character serial using [A-Za-z0-9._-]. File lifecycle is external to this module."
  type = map(object({
    source_file = string
    serial      = string
  }))
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for dev in keys(var.existing_disks) : can(regex("^vd[b-z]$", dev))])
    error_message = "existing_disks keys must be virtio targets vdb through vdz (vda is reserved for boot)."
  }

  validation {
    condition = alltrue([
      for disk in values(var.existing_disks) : try(
        can(regex("^/[^[:space:]]+$", disk.source_file)) &&
        !can(regex("(^|/)\\.{1,2}(/|$)|//|/$", disk.source_file)),
        false
      )
    ])
    error_message = "Each existing disk must be non-null with an absolute, non-root source_file without whitespace, repeated/trailing slashes, or dot/dotdot path components."
  }

  validation {
    condition = alltrue([
      for disk in values(var.existing_disks) : can(regex("^[A-Za-z0-9._-]{1,20}$", try(disk.serial, null)))
    ])
    error_message = "Each existing disk must have a non-null serial of 1-20 characters using [A-Za-z0-9._-]."
  }

  validation {
    condition     = length(distinct([for disk in values(var.existing_disks) : try(disk.source_file, null)])) == length(var.existing_disks)
    error_message = "existing_disks source_file values must be unique."
  }

  validation {
    condition     = length(distinct([for disk in values(var.existing_disks) : try(disk.serial, null)])) == length(var.existing_disks)
    error_message = "existing_disks serial values must be unique."
  }
}

variable "bridge_name" {
  description = "Name of the network bridge for the second network interface."
  type        = string
  default     = "nm-bridge"
}

variable "autostart" {
  description = "Whether the domain should start automatically when libvirtd starts."
  type        = bool
  default     = false
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
  description = "The template content for cloud-init user-data template."
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
