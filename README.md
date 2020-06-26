# CIP Core (Generic Profile) Demonstration and Test Images

This generates bootable images for virtual and physical targets using the
Debian package set of the [CIP](https://www.cip-project.org/) Core Generic
Profile and the CIP SLTS kernel.

The build system used for this is [Isar](https://github.com/ilbers/isar), an
image generator that assembles Debian binaries or builds individual packages
from scratch.

## Building Target Images

Install `kas-docker` from the [kas project](https://github.com/siemens/kas):

    wget https://raw.githubusercontent.com/siemens/kas/master/kas-docker
    chmod a+x kas-docker

Furthermore, install docker and make sure you have required permissions to
start containers.

To build, e.g., the QEMU AMD64 target inside Docker, invoke kas-docker like
this:

    ./kas-docker --isar build kas-cip.yml:kas/board/qemu-amd64.yml

This image can be run using `start-qemu.sh x86`.

The BeagleBone Black target is selected by `... kas-cip.yml:kas/board/bbb.yml`. In
order to build the image with the PREEMPT-RT kernel, append `:kas/opt/rt.yml` to
the above. Append `:kas/opt/4.4.yml` to use the kernel version 4.4 instead of 4.19.

Physical targets will generate ready-to-boot images under
`build/tmp/deploy/images/`. To flash, e.g., the BeagleBone Black image to an SD
card, run

    dd if=build/tmp/deploy/images/bbb/cip-core-image-cip-core-buster-bbb.wic.img \
       of=/dev/<medium-device> bs=1M status=progress

## Community Resources

TBD

## License

Unless otherwise stated in the respective file, files in this layer are
provided under the MIT license, see COPYING file. Patches (files ending with
.patch) are licensed according to their target project and file, typically
GPLv2.
