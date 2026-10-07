# restore UKI Backup in case of snapper restore
when restoring via BTRFS assistant restore to a older snapshot, 
you will notice there isn't a UKI image in /boot/ and it will faile to load and root will be locked

## method 1 boot menu entry
choose the corrosponding UKI latest or LTS boot menu option to backup UKI to `/boot/EFI/Linux/`

## method 2 live USB

- boot live arch linux USB
- mount the EFI partition
```bash
mount /dev/nvme0n1p1 /mnt
```
- copy the backed up UKI images
```bash
cp /mnt/EFI/Linux-backup/* /mnt/EFI/Linux/
```
- unmount and reboot
```bash
umount /mnt
reboot
```

