# SWUpdate support for the CIP core image

This document describes how to build and test the SWUpdate pre-integration for
isar-cip-core, targeting a QEMU x86 virtual machine.

Start with cloning the isar-cip-core repository:
```
host$ git clone https://gitlab.com/cip-project/cip-core/isar-cip-core.git
```

# Building and testing the CIP Core image

Set up `kas-container` as described in the [top-level README](../README.md).
Then build the image which will later serve as update package:
```
host$ ./kas-container build kas-cip.yml:kas/board/qemu-amd64.yml:kas/opt/ebg-swu.yml
```
Save the generated swu `build/tmp/deploy/images/qemu-amd64/cip-core-image-cip-core-bullseye-qemu-amd64.swu` into a separate folder (ex: /tmp).

Next, rebuild the image, switching to the RT kernel as modification:
```
host$ ./kas-container build kas-cip.yml:kas/board/qemu-amd64.yml:kas/opt/ebg-swu.yml:kas/opt/rt.yml
```

Now start the image which will contain the RT kernel:
```
host$ SWUPDATE_BOOT=y ./start-qemu.sh amd64
```

Copy `cip-core-image-cip-core-bullseye-qemu-amd64.swu` file from `tmp` folder into the running system:
```
host$ scp -P 22222 /tmp/cip-core-image-cip-core-bullseye-qemu-amd64.swu root@localhost:
```

## SWUpdate verification

Check which partition is booted, e.g. with lsblk:
```
root@demo:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0    2G  0 disk
├─sda1   8:1    0 16.4M  0 part
├─sda2   8:2    0   32M  0 part
├─sda3   8:3    0   32M  0 part
├─sda4   8:4    0 1000M  0 part /
└─sda5   8:5    0 1000M  0 part
```

Also check that you are running the RT kernel:
```
root@demo:~# uname -a
Linux demo 4.19.233-cip69-rt24 #1 SMP PREEMPT RT Tue Apr 12 09:23:51 UTC 2022 x86_64 GNU/Linux
root@demo:~# ls /lib/modules
4.19.233-cip69-rt24
root@demo:~# cat /sys/kernel/realtime
1
```

Now apply swupdate and reboot
```
root@demo:~# swupdate -i cip-core-image-cip-core-bullseye-qemu-amd64.swu
root@demo:~# reboot
```

Check which partition is booted, e.g. with lsblk and the rootfs should have changed
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

Check the active kernel:
```
root@demo:~# uname -a
Linux demo 4.19.235-cip70 #1 SMP Tue Apr 12 09:08:39 UTC 2022 x86_64 GNU/Linux
root@demo:~# ls /lib/modules
4.19.235-cip70
```

Check bootloader ustate after swupdate
```
root@demo:~# bg_printenv

----------------------------
 Config Partition #0 Values:
in_progress:      no
revision:         2
kernel:           C:BOOT0:linux.efi
kernelargs:       console=tty0 console=ttyS0,115200 rootwait earlyprintk
watchdog timeout: 60 seconds
ustate:           0 (OK)

user variables:



----------------------------
 Config Partition #1 Values:
in_progress:      no
revision:         3
kernel:           C:BOOT1:linux.efi
kernelargs:       console=tty0 console=ttyS0,115200 rootwait earlyprintk
watchdog timeout: 60 seconds
ustate:           2 (TESTING)

user variables:


```

If Partition #1 ustate is 2 (TESTING) then execute below command to confirm swupdate and the command will set ustate to "OK".
```
root@demo:~# bg_setenv -c
```

## SWUpdate rollback example

Build the image for swupdate with a service which causes kernel panic during system boot using below command:

```
host$ ./kas-container build kas-cip.yml:kas/board/qemu-amd64.yml:kas/opt/ebg-swu.yml:kas/opt/kernel-panic.yml
```
Save the generated swu `build/tmp/deploy/images/qemu-amd64/cip-core-image-cip-core-bullseye-qemu-amd64.swu` in a separate folder.
Then build the image without `kernel-panic.yml` recipe using below command:
```
host$ ./kas-container build kas-cip.yml:kas/board/qemu-amd64.yml:kas/opt/ebg-swu.yml
```

Start the target on QEMU:
```
host$ SWUPDATE_BOOT=y ./start-qemu.sh amd64
```

Copy `cip-core-image-cip-core-bullseye-qemu-amd64.swu` file from `tmp` folder into the running system:
```
host$ scp -P 22222 /tmp/cip-core-image-cip-core-bullseye-qemu-amd64.swu root@localhost:
```

Apply swupdate as below:
```
root@demo:~# swupdate -i cip-core-image-cip-core-bullseye-qemu-amd64.swu
```

Check bootloader ustate after swupdate. If the swupdate is successful then **revision number** should be **3** and status should be changed to **INSTALLED** for Partition #1.
```
root@demo:~# bg_printenv

----------------------------
 Config Partition #0 Values:
in_progress:      no
revision:         2
kernel:           C:BOOT0:linux.efi
kernelargs:       console=tty0 console=ttyS0,115200 rootwait earlyprintk
watchdog timeout: 60 seconds
ustate:           0 (OK)

user variables:



----------------------------
 Config Partition #1 Values:
in_progress:      no
revision:         3
kernel:           C:BOOT1:linux.efi
kernelargs:       console=tty0 console=ttyS0,115200 rootwait earlyprintk
watchdog timeout: 60 seconds
ustate:           1 (INSTALLED)

user variables:


```

Execute the reboot command.
```
root@demo:~# reboot
```

The new kernel should cause a kernel panic error.
The watchdog timer should expire and restart the VM (it will take 2 minutes due to an issue in.
The bootloader will then select the previous, working partition and boot from it.

Once the system is restarted, check the bootloader ustate.
If update is failed then **revision number** should be reduced to **0** and status should have changed to **FAILED** for Partition #1.
```
root@demo:~# bg_printenv

----------------------------
 Config Partition #0 Values:
in_progress:      no
revision:         2
kernel:           C:BOOT0:linux.efi
kernelargs:       console=tty0 console=ttyS0,115200 rootwait earlyprintk
watchdog timeout: 60 seconds
ustate:           0 (OK)

user variables:



----------------------------
 Config Partition #1 Values:
in_progress:      no
revision:         0
kernel:           C:BOOT1:linux.efi
kernelargs:       console=tty0 console=ttyS0,115200 rootwait earlyprintk
watchdog timeout: 60 seconds
ustate:           3 (FAILED)

user variables:


```

# Building and testing the CIP Core image for BBB

Follow the steps mentioned in the section [Building and testing the CIP Core image](README.swupdate.md#building-and-testing-the-cip-core-image) for creating images and .swu files.
- Replace qemu-amd64.yml kas file with BBB board specific file i.e bbb.yml
- .swu file will be generated in the following folder build/tmp/deploy/images/bbb/
- Create Non-RT and RT Kernel images as mentioned in the section

Flash the BeagleBone Black RT kernel image into SDcard
```
host$ dd if=build/tmp/deploy/images/bbb/cip-core-image-cip-core-bullseye-bbb.wic \
   of=/dev/<medium-device> bs=1M status=progress
```

After flashing the BBB RT kernel image into SD card, mount the SD card on host PC and copy .swu file from `tmp` folder to root partition like below.

```
host$ sudo cp tmp/cip-core-image-cip-core-bullseye-bbb.swu /<mnt>/home/root/
```

Connect a serial port cable between host PC and BBB.
Insert SD card to BBB, hold S2 button while applying power supply to BBB.

For verifying swupdate on BBB use the same steps as mentioned in above [SWUpdate Verification](README.swupdate.md#swupdate-verification).
