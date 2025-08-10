#!/bin/bash

lb config \
  --apt apt \
  --apt-indices false \
  --apt-options "--yes -oAcquire::Languages=none -oAcquire::PDiffs=false -oAPT::Install-Recommends=0 -oAPT::Install-Suggests=0 -oDpkg::Progress-Fancy=true" \
  --apt-recommends false \
  --apt-source-archives false \
  --architecture amd64 \
  --binary-image iso-hybrid \
  --bootappend-live "boot=live components loglevel=3" \
  --bootappend-live-failsafe "boot=live components memtest noapic noapm nodma nomce nolapic nomodeset nosmp nosplash vga=normal" \
  --bootloaders "syslinux,grub-efi" \
  --checksums none \
  --debian-installer none \
  --debootstrap-options "--variant=minbase" \
  --distribution trixie \
  --iso-volume "trixie" \
  --archive-areas "main contrib non-free non-free-firmware" \
  --parent-archive-areas "main contrib non-free non-free-firmware" \
  --linux-packages "linux-image linux-headers" \
  --firmware-chroot false
