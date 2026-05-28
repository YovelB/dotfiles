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
# sbctl is incredibly smart, it will automatically find your UKIs and systemd-boot files and sign them all at once:
sudo sbctl sign-all
# verify everything is signed correctly
sbctl verify
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
```

note: it will ask to type the LUKS passphrase again to authorize the binding
and on next reboot the TPM2 chip will verify that the secure boot is active and UKI is not tampered with  
and it will allow to bypass the LUKS passphrase by injecting a decryption key
