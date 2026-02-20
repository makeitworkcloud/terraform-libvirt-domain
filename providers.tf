terraform {
  required_version = ">= 1.3"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9.0"
    }
    aap = {
      source  = "registry.terraform.io/ansible/aap"
      version = "~> 1.4.0"
    }
  }
}
