# ISAR CIP Core: Instructions for the Renesas IWG20M board

Version: 20190606
Copyright: Toshiba corp.

## Build the CIP Core image

Set up `kas-container` as described in the [top-level README](../README.md).
Then build the image:

```
$ ./kas-container build kas-cip.yml:kas/board/iwg20m.yml
```

Note: Currently this board is only supported by the CIP kernel version `4.4.y`.

After the build is finished, insert a micro SDCard and flash the image with `bmaptool` (a better `dd`). Make sure you substitute `/dev/sdX` by the device file corresponding to your SDCard.

```
$ sudo apt install bmap-tools
$ sudo bmaptool copy --bmap build/tmp/deploy/images/iwg20m/cip-core-image-cip-core-iwg20m.wic.img.bmap build/tmp/deploy/images/iwg20m/cip-core-image-cip-core-iwg20m.wic.img /dev/sdX
```

[Note] If you cannot use `bmaptool` then use `dd` instead.

## U-boot settings


In order to boot from the micro SDCard, we need to set some environment variables on u-boot. Insert the card on the microSD slot (on the upper hardware module), and a USB-serial cable to the USB Debug port (on the lower hardware module). Open a serial terminal (here we use `picocom`), and then switch on the board and enter the u-boot interactive command line to set the environment variables.

```
$ picocom -b 115200 /dev/ttyUSB0
iWave-G20M > setenv bootargs_msd 'setenv bootargs ${bootargs_base} root=/dev/mmcblk0p2 rw rootfstype=ext4 rootwait'
iWave-G20M > setenv bootcmd_msd 'run bootargs_msd;run fdt_check;mmc dev 1;fatload mmc 1 ${loadaddr} zImage;fatload mmc 1 ${fdt_addr} r8a7743-iwg20d-q7-dbcm-ca.dtb;bootz ${loadaddr} - ${fdt_addr}'
iWave-G20M > saveenv
```

Note that `mmcblk0p2` represents the SDCard when running the CIP kernel 4.4. Once the environment variables are setup, you can boot from the SDCard as follows

```
iWave-G20M > run bootcmd_msd
```

Finally, to make that persistent set the `bootcmd` variable.

```
iWave-G20M > setenv bootcmd 'run bootcmd_msd'
```
