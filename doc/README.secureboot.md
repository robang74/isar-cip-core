# Efibootguard Secure boot

This document describes how to generate a secure boot capable image with
[efibootguard](https://github.com/siemens/efibootguard).

## Description

The image build signs the efibootguard bootloader (bootx64.efi) and generates
a signed [unified kernel image](https://systemd.io/BOOT_LOADER_SPECIFICATION/).
A unified kernel image packs the kernel, initramfs and the kernel command-line
in one binary object. As the kernel command-line is immutable after the build
process, the previous selection of the root file system with a command-line parameter is no longer
possible. Therefore the selection of the root file-system occurs now in the initramfs.

The image uses an A/B partition layout to update the root file system. The sample implementation to
select the root file system generates a uuid and stores the id in /etc/os-release and in the initramfs.
During boot the initramfs compares its own uuid with the uuid stored in /etc/os-release of each rootfs.
If a match is found the rootfs is used for the boot.

## Adaptation for Images

###  WIC
The following elements must be present in a wks file to create a secure boot capable image.

```
part --source efibootguard-efi  --sourceparams "signwith=<script or executable to sign the image>"
part --source efibootguard-boot --sourceparams "uefikernel=<name of the unified kernel>,signwith=<script or executable to sign the image>"
```

#### Script or executable to sign the image

The wic plugins for the [bootloader](./scripts/lib/wic/plugins/source/efibootguard-efi.py)
and [boot partition](./scripts/lib/wic/plugins/source/efibootguard-boot.py) require an
executable or script with the following interface:
```
<script_name> <inputfile> <outputfile>
```
- script name: name and path of the script added with
`--sourceparams "signwith=/usr/bin/sign_secure_image.sh"` to the wic image
- inputfile: path and name of the file to be signed
- outputfile: path and name of the signed input

Supply the script name and path to wic by adding
`signwith=<path and name of the script to sign>"` to sourceparams of the partition.


### Existing packages to sign an image

#### ebg-secure-boot-snakeoil

This package uses the snakeoil key and certificate from the ovmf package(0.0~20200229-2)
backported from Debian bullseye and signs the image.

#### ebg-secure-boot-secrets
This package takes a user-generated certificate and adds it to the build system.
The following variable and steps are necessary to build a secure boot capable image:
- Set certification information to sign and verify the image with:
    - SB_CERTDB: The directory containing the certificate database create with certutil
    - SB_VERIFY_CERT: The certificate to verify the signing process
    - SB_KEY_NAME: Name of the key in the certificate database
- if necessary change the script to select the boot partition after an update
    - recipes-support/initramfs-config/files/initramfs.selectrootfs.script

The files referred by SB_CERTDB and SB_VERIFY_CERT must be store in  `recipes-devtools/ebg-secure-boot-secrets/files/`

## QEMU

Set up a secure boot test environment with [QEMU](https://www.qemu.org/)

### Prerequisites

- OVMF from edk2 release edk2-stable201911 or newer
  - This documentation was tested under Debian 10 with OVMF (0.0~20200229-2) backported from Debian
  bullseye
- efitools for KeyTool.efi
  - This documentation was tested under Debian 10 with efitools (1.9.2-1) backported from Debian bullseye
- libnss3-tools

### Debian Snakeoil keys

The build copies the  Debian Snakeoil keys to the directory `./build/tmp/deploy/images/<machine>/OVMF.
You can use them as described in section [Start Image](### Start the image).

### Generate Keys

#### Reuse exiting keys

It is possible to use exiting keys like /usr/share/ovmf/PkKek-1-snakeoil.pem' from Debian
by executing the script  `scripts/generate-sb-db-from-existing-certificate.sh`, e.g.:
```
export SB_NAME=<name for the secureboot config>
export SB_KEYDIR=<location to store the database>
export INKEY=<secret key of the certificate>
export INCERT=<certificate>
export INNICK=<name of the certificate in the database>
scripts/generate-sb-db-from-existing-certificate.sh
```
This will create the directory `SB_KEYDIR` and will store the `${SB_NAME}certdb` with the given name.

Copy the used certificate and database to `recipes-devtools/ebg-secure-boot-secrets/files/`

#### Generate keys

To generate the necessary keys and information to test secure-boot with QEMU
execute the script `scripts/generate_secure_boot_keys.sh`

##### Add Keys to OVMF
1. Create a folder and copy the generated keys and KeyTool.efi
(in Debian the file can be found at: /lib/efitools/x86_64-linux-gnu/KeyTool.efi) to the folder
```
mkdir secureboot-tools
cp -r keys secureboot-tools
cp /lib/efitools/x86_64-linux-gnu/KeyTool.efi secureboot-tools
```
2. Copy the file OVMF_VARS_4M.fd (in Debian the file can be found at /usr/share/OVMF/OVMF_VARS_4M.fd)
to the current directory. OVMF_VARS_4M.fd contains no keys can be instrumented for secureboot.
3. Start QEMU with the script scripts/start-efishell.sh
```
scripts/start-efishell.sh secureboot-tools
```
4. Start the KeyTool.efi FS0:\KeyTool.efi and execute the the following steps:
          -> "Edit Keys"
             -> "The Allowed Signatures Database (db)"
                -> "Add New Key"
                -> Change/Confirm device
                -> Select "DB.esl" file
             -> "The Key Exchange Key Database (KEK)"
                -> "Add New Key"
                -> Change/Confirm device
                -> Select "KEK.esl" file
             -> "The Platform Key (PK)
                -> "Replace Key(s)"
                -> Change/Confirm device
                -> Select "PK.auth" file
5. quit QEMU

### Build image

Build the image with a signed efibootguard and unified kernel image
with the snakeoil keys by executing:
```
kas-container build kas-cip.yml:kas/board/qemu-amd64.yml:kas/opt/ebg-swu.yml:kas/opt/ebg-secure-boot-snakeoil.yml
```

For user-generated keys, create a new option file. This option file could look like this:
```
header:
  version: 10
  includes:
   - opt/ebg-swu.yml
   - opt/ebg-secure-boot-initramfs.yml

local_conf_header:
  secure-boot: |
    IMAGER_BUILD_DEPS += "ebg-secure-boot-secrets"
    IMAGER_INSTALL += "ebg-secure-boot-secrets"
  user-keys:
    SB_CERTDB = "democertdb"
    SB_VERIFY_CERT = "demo.crt"
    SB_KEY_NAME = "demo"
```

Replace `demo` with the name of the user-generated certificates.

### Start the image

#### Debian snakeoil

Start the image with the following command:
```
SECURE_BOOT=y \
./start-qemu.sh amd64
```

The default `OVMF_VARS.snakeoil_4M.fd` boot to the EFI shell. To boot Linux enter the following command:
```
FS0:\EFI\BOOT\bootx64.efi
```
To change the boot behavior, enter `exit` in the shell to enter the bios and change the boot order.

#### User-generated keys
Start the image with the following command:
```
SECURE_BOOT=y \
OVMF_CODE=./build/tmp/deploy/images/qemu-amd64/OVMF/OVMF_CODE_4M.secboot.fd \
OVMF_VARS=<path to the modified OVMF_VARS.fd> \
./start-qemu.sh amd64
```
# Example: Update the image

For updating the image, the following steps are necessary:
- [Build the image with snakeoil keys](### Build image)
- save the generated swu `build/tmp/deploy/images/qemu-amd64/cip-core-image-cip-core-buster-qemu-amd64.swu` to /tmp
- modify the image for example add a new version to the image by adding `PV=2.0.0` to
  [cip-core-image.bb](recipes-core/images/cip-core-image.bb)
- start the new target and copy the swu `cip-core-image-cip-core-buster-qemu-amd64.swu`
  to the running system, e.g.:
```
SECURE=y ./start-qemu.sh amd64 -virtfs local,path=/tmp,mount_tag=host0,security_model=passthrough,id=host0
```
- mount `host0` on target with:
```
mount -t 9p -o trans=virtio,version=9p2000.L host0 /mnt
```
- check which partition is booted, e.g. with `lsblk`:
```
root@demo:/mnt# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0    2G  0 disk
├─sda1   8:1    0 16.4M  0 part
├─sda2   8:2    0   32M  0 part
├─sda3   8:3    0   32M  0 part
├─sda4   8:4    0 1000M  0 part /
└─sda5   8:5    0 1000M  0 part
```

- install with `swupdate -i /mnt/cip-core-image-cip-core-buster-qemu-amd64.swu`
- reboot
- check which partition is booted, e.g. with `lsblk`. The rootfs should have changed:
```
root@demo:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0    2G  0 disk
├─sda1   8:1    0 16.4M  0 part
├─sda2   8:2    0   32M  0 part
├─sda3   8:3    0   32M  0 part
├─sda4   8:4    0 1000M  0 part
└─sda5   8:5    0 1000M  0 part /
```
