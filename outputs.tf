output "domain_id" {
  description = "The ID of the libvirt domain"
  value       = libvirt_domain.vm.id
}

output "domain_name" {
  description = "The name of the libvirt domain"
  value       = libvirt_domain.vm.name
}

output "boot_volume_id" {
  description = "The ID of the boot volume"
  value       = libvirt_volume.boot.id
}

output "cloudinit_disk_id" {
  description = "The ID of the cloud-init disk"
  value       = libvirt_cloudinit_disk.commoninit.id
}
