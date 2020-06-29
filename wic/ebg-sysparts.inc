# default partition layout EFI Boot Guard usage

# EFI partition containing efibootguard bootloader binary
part --source efibootguard-efi  --ondisk sda --size 16M --extra-space 0 --overhead-factor 1 --label efi   --align 1024 --part-type=EF00 --active

# EFI Boot Guard environment/config partitions plus Kernel files
part --source efibootguard-boot --ondisk sda --size 32M --extra-space 0 --overhead-factor 1 --label BOOT0 --align 1024 --part-type=0700 --sourceparams "revision=2,root=PARTUUID:fedcba98-7654-3210-cafe-5e0710000001"
part --source efibootguard-boot --ondisk sda --size 32M --extra-space 0 --overhead-factor 1 --label BOOT1 --align 1024 --part-type=0700 --sourceparams "revision=1,root=PARTUUID:fedcba98-7654-3210-cafe-5e0710000002"
