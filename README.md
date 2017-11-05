# furry-happiness

## Summary
Basic install/setup script for Arch Linux

## Packages installed
base
base-devel
nmap
htop
screen
reflector
grub
vim
net-tools
openssh

## Notes
Currently there are NO options to pass to the script.

### Right now:
- Install Arch Linux on the largest drive
- Partion table with MBR/BIOS 
- Creates a swap partition of 2G and a root partion (/) with the rest of the drive
- Assumes Eastern, United States for language/mirror/timezone selection
- Assumes wired internet with DHCP
- Uses reflector to find the fastest mirrors in the US
- Assumes GRUB for bootloader
- Default password for root is set to "password"
