mock_provider "libvirt" {}

variables {
  name                              = "test-vm"
  boot_image_url                    = "https://example.invalid/base.qcow2"
  cloudinit_meta_data_template      = "tests/fixtures/cloud-init.tftpl"
  cloudinit_meta_data_vars          = {}
  cloudinit_user_data_template      = "tests/fixtures/cloud-init.tftpl"
  cloudinit_user_data_vars          = {}
  cloudinit_network_config_template = "tests/fixtures/cloud-init.tftpl"
  cloudinit_network_config_vars     = {}
}

run "defaults_preserve_disks_and_volume_count" {
  command = plan

  plan_options {
    refresh = false
  }

  assert {
    condition     = length(libvirt_domain.vm.devices.disks) == 2 && libvirt_domain.vm.devices.disks[0].target.dev == "vda" && libvirt_domain.vm.devices.disks[1].target.dev == "sda" && libvirt_domain.vm.devices.disks[1].device == "cdrom"
    error_message = "Default disks must remain boot then cloud-init cdrom."
  }

  assert {
    condition     = length(libvirt_volume.extra) == 0 && libvirt_domain.vm.devices.disks[0].source.volume.volume == libvirt_volume.boot.name && libvirt_domain.vm.devices.disks[0].driver.type == "qcow2"
    error_message = "Default boot attachment and managed extra-volume count must not change."
  }
}

run "null_map_uses_empty_default" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = null
  }

  assert {
    condition     = length(libvirt_domain.vm.devices.disks) == 2 && libvirt_domain.vm.devices.disks[0].target.dev == "vda" && libvirt_domain.vm.devices.disks[1].target.dev == "sda" && length(libvirt_volume.extra) == 0
    error_message = "nullable=false must use the empty default for a null map."
  }
}

run "existing_files_do_not_create_managed_volumes" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdb = {
        source_file = "/srv/retained/ssd.raw"
        serial      = "k3s-retained-ssd"
      }
    }
  }

  assert {
    condition     = length(libvirt_volume.extra) == 0 && length(libvirt_domain.vm.devices.disks) == 3 && libvirt_domain.vm.devices.disks[1].source.file.file == "/srv/retained/ssd.raw"
    error_message = "An existing file must add only a domain attachment, not a managed volume."
  }
}

run "managed_then_sorted_existing_then_cdrom" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    extra_volumes = [{ name = "extra.qcow2", size = 1073741824 }]
    existing_disks = {
      vdd = {
        source_file = "/srv/retained/nvme.raw"
        serial      = "k3s-retained-nvme"
      }
      vdc = {
        source_file = "/srv/retained/ssd.raw"
        serial      = "k3s-retained-ssd"
      }
    }
  }

  assert {
    condition     = [for disk in libvirt_domain.vm.devices.disks : disk.target.dev] == ["vda", "vdb", "vdc", "vdd", "sda"]
    error_message = "Disks must remain boot, managed extras, key-sorted existing disks, then cdrom."
  }

  assert {
    condition     = length(libvirt_volume.extra) == 1 && libvirt_domain.vm.devices.disks[1].source.volume.volume == libvirt_volume.extra[0].name && libvirt_domain.vm.devices.disks[4].device == "cdrom"
    error_message = "Existing files must not change managed extra-volume count or attachment."
  }

  assert {
    condition = alltrue([
      for idx, dev in ["vdc", "vdd"] :
      libvirt_domain.vm.devices.disks[idx + 2].source.file.file == var.existing_disks[dev].source_file &&
      libvirt_domain.vm.devices.disks[idx + 2].serial == var.existing_disks[dev].serial &&
      libvirt_domain.vm.devices.disks[idx + 2].driver.name == "qemu" &&
      libvirt_domain.vm.devices.disks[idx + 2].driver.type == "raw" &&
      libvirt_domain.vm.devices.disks[idx + 2].driver.discard == "unmap" &&
      libvirt_domain.vm.devices.disks[idx + 2].target.bus == "virtio"
    ])
    error_message = "Existing disks must use raw file sources, stable serials, virtio, and discard=unmap."
  }
}

run "serial_boundaries_and_last_target" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdb = { source_file = "/srv/a.raw", serial = "a" }
      vdz = { source_file = "/srv/z.raw", serial = "0123456789ABCDEF._-x" }
    }
  }

  assert {
    condition     = libvirt_domain.vm.devices.disks[2].target.dev == "vdz" && libvirt_domain.vm.devices.disks[2].serial == "0123456789ABCDEF._-x"
    error_message = "One- and twenty-character serials and vdz must be accepted."
  }
}

run "target_collision_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    extra_volumes = [{ name = "extra.qcow2", size = 1073741824 }]
    existing_disks = {
      vdb = { source_file = "/srv/a.raw", serial = "disk-a" }
    }
  }

  expect_failures = [libvirt_domain.vm]
}

run "later_target_collision_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    extra_volumes = [
      { name = "extra-a.qcow2", size = 1073741824 },
      { name = "extra-b.qcow2", size = 1073741824 }
    ]
    existing_disks = {
      vdc = { source_file = "/srv/a.raw", serial = "disk-a" }
    }
  }

  expect_failures = [libvirt_domain.vm]
}

run "boot_target_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vda = { source_file = "/srv/a.raw", serial = "disk-a" }
    }
  }

  expect_failures = [var.existing_disks]
}

run "invalid_target_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdaa = { source_file = "/srv/a.raw", serial = "disk-a" }
    }
  }

  expect_failures = [var.existing_disks]
}

run "relative_path_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdb = { source_file = "srv/a.raw", serial = "disk-a" }
    }
  }

  expect_failures = [var.existing_disks]
}

run "root_path_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdb = { source_file = "/", serial = "disk-a" }
    }
  }

  expect_failures = [var.existing_disks]
}

run "whitespace_path_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdb = { source_file = "/srv/a raw", serial = "disk-a" }
    }
  }

  expect_failures = [var.existing_disks]
}

run "dot_path_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdb = { source_file = "/srv/./a.raw", serial = "disk-a" }
    }
  }

  expect_failures = [var.existing_disks]
}

run "dotdot_path_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdb = { source_file = "/srv/../a.raw", serial = "disk-a" }
    }
  }

  expect_failures = [var.existing_disks]
}

run "empty_serial_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdb = { source_file = "/srv/a.raw", serial = "" }
    }
  }

  expect_failures = [var.existing_disks]
}

run "long_serial_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdb = { source_file = "/srv/a.raw", serial = "012345678901234567890" }
    }
  }

  expect_failures = [var.existing_disks]
}

run "invalid_serial_character_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdb = { source_file = "/srv/a.raw", serial = "disk/a" }
    }
  }

  expect_failures = [var.existing_disks]
}

run "null_object_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = { vdb = null }
  }

  expect_failures = [var.existing_disks]
}

run "null_source_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdb = { source_file = null, serial = "disk-a" }
    }
  }

  expect_failures = [var.existing_disks]
}

run "null_serial_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdb = { source_file = "/srv/a.raw", serial = null }
    }
  }

  expect_failures = [var.existing_disks]
}

run "duplicate_sources_are_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdb = { source_file = "/srv/a.raw", serial = "disk-a" }
      vdc = { source_file = "/srv/a.raw", serial = "disk-b" }
    }
  }

  expect_failures = [var.existing_disks]
}

run "duplicate_serials_are_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    existing_disks = {
      vdb = { source_file = "/srv/a.raw", serial = "disk-a" }
      vdc = { source_file = "/srv/b.raw", serial = "disk-a" }
    }
  }

  expect_failures = [var.existing_disks]
}
