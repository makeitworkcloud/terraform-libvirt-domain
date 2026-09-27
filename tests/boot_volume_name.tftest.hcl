mock_provider "libvirt" {}

variables {
  name                             = "test-vm"
  boot_image_url                   = "https://example.invalid/base.qcow2"
  cloudinit_meta_data_template      = "tests/fixtures/cloud-init.tftpl"
  cloudinit_meta_data_vars          = {}
  cloudinit_user_data_template      = "tests/fixtures/cloud-init.tftpl"
  cloudinit_user_data_vars          = {}
  cloudinit_network_config_template = "tests/fixtures/cloud-init.tftpl"
  cloudinit_network_config_vars     = {}
}

run "omitted_token_preserves_public_name" {
  command = plan

  plan_options {
    refresh = false
  }

  assert {
    condition     = local.boot_volume_name == "${var.name}-${substr(sha256(var.boot_image_url), 0, 8)}.qcow2"
    error_message = "Omitting the rebuild token must preserve the historical boot-volume name."
  }

  assert {
    condition     = !issensitive(local.boot_volume_name) && !issensitive(libvirt_volume.boot.name) && !issensitive(libvirt_domain.vm.devices.disks[0].source.volume.volume)
    error_message = "The omitted token must not mark boot names or domain disk references sensitive."
  }
}

run "explicit_null_preserves_public_name" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    boot_rebuild_token = null
  }

  assert {
    condition     = local.boot_volume_name == "${var.name}-${substr(sha256(var.boot_image_url), 0, 8)}.qcow2"
    error_message = "An explicit null rebuild token must preserve the historical boot-volume name."
  }

  assert {
    condition     = !issensitive(local.boot_volume_name) && !issensitive(libvirt_volume.boot.name) && !issensitive(libvirt_domain.vm.devices.disks[0].source.volume.volume)
    error_message = "An explicit null token must not mark boot names or domain disk references sensitive."
  }
}

run "supplied_token_retains_sensitive_hash" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    boot_rebuild_token = "fixture-rebuild-a"
  }

  assert {
    condition     = nonsensitive(local.boot_volume_name == "${var.name}-${substr(sha256(var.boot_image_url), 0, 8)}-${substr(sha256("fixture-rebuild-a"), 0, 8)}.qcow2")
    error_message = "A supplied rebuild token must contribute only its hash prefix to the boot-volume name."
  }

  assert {
    condition     = issensitive(var.boot_rebuild_token) && issensitive(local.boot_volume_name) && issensitive(libvirt_volume.boot.name) && issensitive(libvirt_domain.vm.devices.disks[0].source.volume.volume)
    error_message = "A supplied token and its derived boot names must remain sensitive."
  }
}

run "different_token_changes_sensitive_name" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    boot_rebuild_token = "fixture-rebuild-b"
  }

  assert {
    condition     = nonsensitive(local.boot_volume_name == "${var.name}-${substr(sha256(var.boot_image_url), 0, 8)}-${substr(sha256("fixture-rebuild-b"), 0, 8)}.qcow2" && local.boot_volume_name != "${var.name}-${substr(sha256(var.boot_image_url), 0, 8)}-${substr(sha256("fixture-rebuild-a"), 0, 8)}.qcow2")
    error_message = "Different rebuild tokens must select different boot-volume names."
  }

  assert {
    condition     = issensitive(local.boot_volume_name) && issensitive(libvirt_volume.boot.name) && issensitive(libvirt_domain.vm.devices.disks[0].source.volume.volume)
    error_message = "Changing the token must retain sensitivity on its derived boot names."
  }
}

run "invalid_empty_token_is_rejected" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    boot_rebuild_token = ""
  }

  expect_failures = [var.boot_rebuild_token]
}
