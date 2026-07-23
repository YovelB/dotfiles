# Secure Boot and TPM2 LUKS binding

## Secure Boot setup
- reboot your computer and enter the BIOS/UEFI
- navigate to the Security or Secure Boot section
- find the option to "Clear Secure Boot Keys" or change the OS Type from "Windows UEFI" to "Custom/Setup Mode"
- save and boot back into Arch Linux

next open terminal to run:
```bash
# verify the system is in setup mode
sbctl status
# generate your custom secure boot keys
sudo sbctl create-keys
# enroll your keys + microsoft certificates into the firmware
sudo sbctl enroll-keys -m

# sbctl is is not smart, it doesnt find your UKIs and systemd-boot files and sign them all at once via
# sudo sbctl sign-all (this wont do anything)
# hence, the need to list all unsigned key paths via:
sudo sbctl verify

# then sign all the keys
# sign the systemd-boot bootloader files
sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
sudo sbctl sign -s /boot/EFI/systemd/systemd-bootx64.efi
# sign your Arch Linux Unified Kernel Images (UKIs)
sudo sbctl sign -s /boot/EFI/Linux/arch-linux.efi
sudo sbctl sign -s /boot/EFI/Linux/arch-linux-lts.efi
# sign the standalone kernels (not strictly needed since you boot UKIs, but good practice to clear the warnings)
sudo sbctl sign -s /boot/vmlinuz-linux
sudo sbctl sign -s /boot/vmlinuz-linux-lts

# verify everything is signed correctly
sudo sbctl verify
# check the status before enabling Secure Boot in UEFI
sbctl status
```

reboot your computer, enter the BIOS, and turn Secure Boot ON and boot back into Arch.  
if it boots, Secure Boot is successfully protecting your system.

## TPM2 LUKS passphrase binding
now that there is secure boot, you can bind your hard drive encryption (LUKS passphrase) into the TPM2 chip (if there is one).

```bash
# find the encrpted partition name (like dev/nvme0n1p2):
lsblk -f
# bind the drive to TPM2 chip, measuring the secure boot state (PCR 7):
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
# verify the TPM slot was added:
sudo systemd-cryptenroll /dev/nvme0n1p2
```

note: it will ask to type the LUKS passphrase again to authorize the binding

## bootloader config for TPM2

to allow the early boot environment to communicate with the TPM chip.
switch from the basic encrypt hook to the modern systemd hooks, and update your kernel parameters accordingly.

```bash
# first replace mkinitcpio hooks with systemd equivalent
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)

# get the unique identifier(LUKS UUID) of your encrypted partition
sudo cryptsetup luksUUID /dev/nvme0n1p2
# update kernal parameters
sudo nvim /etc/kernel/cmdline
replace the old cryptdevice=PARTUUID=... syntax with rd.luks.name= syntax, using the LUKS UUID (the rest stays the same)
rd.luks.name=YOUR-LUKS-UUID-HERE=root root=/dev/mapper/root zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs

# lastly rebuild the UKI
sudo mkinitcpio -P
```

and on next reboot the TPM2 chip will verify that the secure boot is active and UKI is not tampered with  
and it will allow to bypass the LUKS passphrase by injecting a decryption key
