resource "libvirt_volume" "boot" {
  name     = "${var.name}-${substr(sha256(var.boot_image_url), 0, 8)}.qcow2"
  pool     = var.storage_pool
  capacity = var.boot_disk_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  create = {
    content = {
      url = var.boot_image_url
    }
  }
}

resource "libvirt_volume" "extra" {
  count    = length(var.extra_volumes)
  name     = var.extra_volumes[count.index].name
  pool     = var.storage_pool
  capacity = var.extra_volumes[count.index].size
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "${var.name}_commoninit"
  meta_data      = templatefile(var.cloudinit_meta_data_template, var.cloudinit_meta_data_vars)
  user_data      = templatefile(var.cloudinit_user_data_template, var.cloudinit_user_data_vars)
  network_config = templatefile(var.cloudinit_network_config_template, var.cloudinit_network_config_vars)
}

# Stable trigger for cloudinit volume replacement: a hash of the actual
# cloud-init data, not the cloudinit_disk's volatile local /tmp path.
resource "terraform_data" "cloudinit_content" {
  input = sha256(jsonencode({
    meta_data      = templatefile(var.cloudinit_meta_data_template, var.cloudinit_meta_data_vars)
    user_data      = templatefile(var.cloudinit_user_data_template, var.cloudinit_user_data_vars)
    network_config = templatefile(var.cloudinit_network_config_template, var.cloudinit_network_config_vars)
  }))
}

resource "libvirt_volume" "cloudinit" {
  name = "${var.name}_cloudinit.iso"
  pool = var.storage_pool

  create = {
    content = {
      url = libvirt_cloudinit_disk.commoninit.path
    }
  }

  # libvirt_cloudinit_disk renders its ISO under a local /tmp path that lives
  # in state. A tofu invocation on a host without that file (CI runner vs
  # laptop, post-reboot /tmp wipe) sees it as drift and rebuilds the disk,
  # producing a new path. The libvirt provider can't update libvirt_volume in
  # place ("Storage volumes cannot be updated"), so the cascading url change
  # used to break every cross-host apply.
  #
  # Ignore url drift entirely; replace the volume only when the cloud-init
  # content itself actually changes (tracked via terraform_data).
  lifecycle {
    ignore_changes = [
      create,
    ]
    replace_triggered_by = [
      terraform_data.cloudinit_content,
    ]
  }
}

resource "libvirt_domain" "vm" {
  name        = var.name
  type        = "kvm"
  description = var.description
  vcpu        = var.vcpu
  memory      = var.memory
  memory_unit = "MiB"
  running     = true
  autostart   = var.autostart

  cpu = {
    mode = "host-passthrough"
  }

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
    boot_devices = [{ dev = "hd" }]
  }

  devices = {
    # Disk ordering: boot disk, extra volumes, then cdrom LAST
    # libvirt returns disks sorted by bus type (virtio before sata/ide)
    # so we must define them in that order to avoid provider inconsistency errors
    disks = concat(
      [
        {
          driver = {
            name = "qemu"
            type = "qcow2"
          }
          source = {
            volume = {
              pool   = var.storage_pool
              volume = libvirt_volume.boot.name
            }
          }
          target = {
            dev = "vda"
            bus = "virtio"
          }
        }
      ],
      [
        for idx, vol in libvirt_volume.extra : {
          source = {
            volume = {
              pool   = var.storage_pool
              volume = vol.name
            }
          }
          target = {
            dev = "vd${substr("bcdefghij", idx, 1)}"
            bus = "virtio"
          }
        }
      ],
      [
        {
          source = {
            volume = {
              pool   = var.storage_pool
              volume = libvirt_volume.cloudinit.name
            }
          }
          target = {
            dev = "sda"
            bus = "sata"
          }
          device = "cdrom"
        }
      ]
    )

    interfaces = [
      {
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = "default"
          }
        }
      },
      {
        model = {
          type = "virtio"
        }
        source = {
          bridge = {
            bridge = var.bridge_name
          }
        }
      }
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "0.0.0.0"
          listeners = [
            {
              address = {
                address = "0.0.0.0"
              }
            }
          ]
        }
      }
    ]
  }

  lifecycle {
    # Force replacement if the boot volume changes
    replace_triggered_by = [
      libvirt_volume.boot
    ]
    # Ignore graphics changes due to similar provider bugs.
    ignore_changes = [
      devices.graphics,
    ]
  }
}
