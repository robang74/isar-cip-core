
Clone the isar-cip-core repository
```
host$ git clone https://gitlab.com/cip-project/cip-core/isar-cip-core.git
```

Build the CIP Core image

Set up `kas-container` as described in the [top-level README](../README.md).
Then build the image:
```
host$ ./kas-container build kas-cip.yml:kas/board/qemu-amd64.yml:kas/opt/ebg-swu.yml
```
- save the generated swu build/tmp/deploy/images/qemu-amd64/cip-core-image-cip-core-buster-qemu-amd64.swu in a separate folder (ex: tmp)
- modify the image for example add a new version to the image by adding PV=2.0.0 to cip-core-image.bb
- rebuild the image using above command and start the new target
```
host$ SWUPDATE_BOOT=y ./start-qemu.sh amd64
```

Copy `cip-core-image-cip-core-buster-qemu-amd64.swu` file from `tmp` folder to the running system

```
root@demo:~# scp <host-user>@10.0.2.2:<path-to-swu-file>/tmp/cip-core-image-cip-core-buster-qemu-amd64.swu .
```

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

Apply swupdate and reboot
```
root@demo:~# swupdate -i cip-core-image-cip-core-buster-qemu-amd64.swu
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

Check bootloader ustate after swupdate
```
root@demo:~# bg_printenv
----------------------------
Config Partition #0 Values:
in_progress:      no
revision:         2
kernel:           C:BOOT0:cip-core-image-cip-core-buster-qemu-amd64-vmlinuz
kernelargs:       console=tty0 console=ttyS0,115200 rootwait earlyprintk root=PARTUUID=fedcba98-7654-3210-cafe-5e0710000001 rw initrd=cip-core-image-cip-core-buster-qemu-amd64-initrd.img
watchdog timeout: 60 seconds
ustate:           0 (OK)

user variables:

----------------------------
 Config Partition #1 Values:
in_progress:      no
revision:         3
kernel:           C:BOOT1:vmlinuz
kernelargs:       root=PARTUUID=fedcba98-7654-3210-cafe-5e0710000002 console=tty0 console=ttyS0,115200 rootwait earlyprintk rw initrd=cip-core-image-cip-core-buster-qemu-amd64-initrd.img
watchdog timeout: 60 seconds
ustate:           2 (TESTING)
```

if Partition #1 usate is 2 (TESTING) then execute below command to confirm swupdate and the command will set ustate to "OK"
```
root@demo:~# bg_setenv -c
```

# swupdate rollback example

Build the image for swupdate with service which causes kernel panic during system boot using below command.

```
host$ ./kas-container build kas-cip.yml:kas/board/qemu-amd64.yml:kas/opt/ebg-swu.yml:kas/opt/kernel-panic.yml
```
- save the generated swu build/tmp/deploy/images/qemu-amd64/cip-core-image-cip-core-buster-qemu-amd64.swu in a separate folder (ex: tmp)
- build the image again without `kernel-panic.yml` recipe using below command
```
host$ ./kas-container build kas-cip.yml:kas/board/qemu-amd64.yml:kas/opt/ebg-swu.yml
```

Start the target on QEMU
```
host$ SWUPDATE_BOOT=y ./start-qemu.sh amd64
```

Copy `cip-core-image-cip-core-buster-qemu-amd64.swu` file from `tmp` folder to the running system

```
root@demo:~# scp <host-user>@10.0.2.2:<path-to-swu-file>/tmp/cip-core-image-cip-core-buster-qemu-amd64.swu .
```

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

Check bootloader ustate before swupdate and should be as below
```
root@demo:~# bg_printenv
----------------------------
Config Partition #0 Values:
in_progress:      no
revision:         2
kernel:           C:BOOT0:cip-core-image-cip-core-buster-qemu-amd64-vmlinuz
kernelargs:       console=tty0 console=ttyS0,115200 rootwait earlyprintk root=PARTUUID=fedcba98-7654-3210-cafe-5e0710000001 rw initrd=cip-core-image-cip-core-buster-qemu-amd64-initrd.img
watchdog timeout: 60 seconds
ustate:           0 (OK)

user variables:
----------------------------
Config Partition #1 Values:
in_progress:      no
revision:         1
kernel:           C:BOOT1:cip-core-image-cip-core-buster-qemu-amd64-vmlinuz
kernelargs:       console=tty0 console=ttyS0,115200 rootwait earlyprintk root=PARTUUID=fedcba98-7654-3210-cafe-5e0710000002 rw initrd=cip-core-image-cip-core-buster-qemu-amd64-initrd.img
watchdog timeout: 60 seconds
ustate:           0 (OK)
```

Apply swupdate as below
```
root@demo:~# swupdate -i cip-core-image-cip-core-buster-qemu-amd64.swu
```

check bootloader ustate after swupdate. if the swupdate is successful then **revision number** should increase to **3** and status should be changed to **INSTALLED** for Partition #1.
```
root@demo:~# bg_printenv
----------------------------
Config Partition #0 Values:
in_progress:      no
revision:         2
kernel:           C:BOOT0:cip-core-image-cip-core-buster-qemu-amd64-vmlinuz
kernelargs:       console=tty0 console=ttyS0,115200 rootwait earlyprintk root=PARTUUID=fedcba98-7654-3210-cafe-5e0710000001 rw initrd=cip-core-image-cip-core-buster-qemu-amd64-initrd.img
watchdog timeout: 60 seconds
ustate:           0 (OK)

user variables:
----------------------------
Config Partition #1 Values:
in_progress:      no
revision:         3
kernel:           C:BOOT1:vmlinuz
kernelargs:       root=PARTUUID=fedcba98-7654-3210-cafe-5e0710000002 console=tty0 console=ttyS0,115200 rootwait earlyprintk rw initrd=cip-core-image-cip-core-buster-qemu-amd64-initrd.img
watchdog timeout: 60 seconds
ustate:           1 (INSTALLED)
```

Execute reboot command
- reboot command should cause kernel panic error.
- watchdog timer should expire and restart the qemu. bootloader should select previous partition to boot.
```
root@demo:~# reboot
```

Once the system is restarted, check the bootloader ustate
- if update is failed then **revision number** should reduce to **0** and status should change to **FAILED** for Partition #1.
```
root@demo:~# bg_printenv
----------------------------
 Config Partition #0 Values:
in_progress:      no
revision:         2
kernel:           C:BOOT0:cip-core-image-cip-core-buster-qemu-amd64-vmlinuz
kernelargs:       console=tty0 console=ttyS0,115200 rootwait earlyprintk root=PARTUUID=fedcba98-7654-3210-cafe-5e0710000001 rw initrd=cip-core-image-cip-corg
watchdog timeout: 60 seconds
ustate:           0 (OK)

user variables:
----------------------------
 Config Partition #1 Values:
in_progress:      no
revision:         0
kernel:           C:BOOT1:vmlinuz
kernelargs:       root=PARTUUID=fedcba98-7654-3210-cafe-5e0710000002 console=tty0 console=ttyS0,115200 rootwait earlyprintk rw initrd=cip-core-image-cip-corg
watchdog timeout: 60 seconds
ustate:           3 (FAILED)
```
