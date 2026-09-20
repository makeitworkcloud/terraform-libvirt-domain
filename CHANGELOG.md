# Changelog

## [1.0.0](https://github.com/makeitworkcloud/terraform-libvirt-domain/compare/v0.1.0...v1.0.0) (2026-09-20)


### ⚠ BREAKING CHANGES

* remove AAP; add boot_disk_size; bundle opencode config ([#2](https://github.com/makeitworkcloud/terraform-libvirt-domain/issues/2))

### Features

* add optional autostart input for libvirt_domain ([#6](https://github.com/makeitworkcloud/terraform-libvirt-domain/issues/6)) ([fcd62ed](https://github.com/makeitworkcloud/terraform-libvirt-domain/commit/fcd62ed0fa87939eb773738c6918dc39b55dbf5d))
* add stale PR dry-run caller ([8a6d686](https://github.com/makeitworkcloud/terraform-libvirt-domain/commit/8a6d68656371da48e3532e142650122228694682))
* updated cloud image to fedora 43 ([cd35a87](https://github.com/makeitworkcloud/terraform-libvirt-domain/commit/cd35a8763d0fc99e9bf339f3525ed0cc3354f161))


### Bug Fixes

* adopt existing release baseline without rewriting tags ([#24](https://github.com/makeitworkcloud/terraform-libvirt-domain/issues/24)) ([e2bfe53](https://github.com/makeitworkcloud/terraform-libvirt-domain/commit/e2bfe53f2d85a9eee156da969e00b40c148ec7d7))
* force replacement of boot volume on image url change ([bd889cd](https://github.com/makeitworkcloud/terraform-libvirt-domain/commit/bd889cd7f821a6142fd5af1e1f04e392df0fbae9))
* reorder disks to match libvirt return order ([372a678](https://github.com/makeitworkcloud/terraform-libvirt-domain/commit/372a67817fb13ec6d3a68b85d4e36f1d1b295414))
* replace cloudinit volume when its source disk changes ([#7](https://github.com/makeitworkcloud/terraform-libvirt-domain/issues/7)) ([d5d1a50](https://github.com/makeitworkcloud/terraform-libvirt-domain/commit/d5d1a502745b93ab4fd1a3adebdbb1534ee4ed37))
* set qcow2 driver type for boot disk ([8c0ef1a](https://github.com/makeitworkcloud/terraform-libvirt-domain/commit/8c0ef1ac837d6198cd2844ca9b47d593d3d86a8e))
* skip branch guard in CI ([#10](https://github.com/makeitworkcloud/terraform-libvirt-domain/issues/10)) ([5a849cf](https://github.com/makeitworkcloud/terraform-libvirt-domain/commit/5a849cfab25285e608caee9105b1d125bec05ef9))
* trigger aap_job recreation when vm is replaced ([f24aae5](https://github.com/makeitworkcloud/terraform-libvirt-domain/commit/f24aae5bbb41adb8e1517b7fb0a8768fbb0e0f87))
* trigger cloudinit volume replacement on content change only ([#8](https://github.com/makeitworkcloud/terraform-libvirt-domain/issues/8)) ([f6626b7](https://github.com/makeitworkcloud/terraform-libvirt-domain/commit/f6626b7c51e6bdc5d4ea34e8019656658e9b783c))
* use q35 machine type for Fedora 42 Cloud boot compatibility ([706a242](https://github.com/makeitworkcloud/terraform-libvirt-domain/commit/706a2424c0727a530a5eaca99dd4621edfdf4244))
* use sata bus for cloudinit cdrom device ([af13382](https://github.com/makeitworkcloud/terraform-libvirt-domain/commit/af133826b81a19c890b65011703fb221ec350907))


### Code Refactoring

* remove AAP; add boot_disk_size; bundle opencode config ([#2](https://github.com/makeitworkcloud/terraform-libvirt-domain/issues/2)) ([be6824e](https://github.com/makeitworkcloud/terraform-libvirt-domain/commit/be6824eaf0f64e9f7181de6a26676402e298fdcf))
