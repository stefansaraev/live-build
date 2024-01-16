#!/bin/bash

for dist in bookworm sid ; do
  pushd $dist
  lb clean
  ./config.sh
  lb build
  popd

  mkdir -p /var/www/boot.test.net.in/live/$dist/
  cp $dist/binary/live/vmlinuz /var/www/boot.test.net.in/live/$dist/
  cp $dist/binary/live/initrd.img /var/www/boot.test.net.in/live/$dist/
  cp $dist/binary/live/filesystem.squashfs /var/www/boot.test.net.in/live/$dist/
  cp $dist/live-image-amd64.hybrid.iso /var/www/boot.test.net.in/live/$dist/

  chmod 644 /var/www/boot.test.net.in/live/$dist/vmlinuz
done
