# UbuntuCryptRootInstaller
(almost) Automatic Ubuntu Installer, With Cryptroot and luksOpen via SSH in Initramfs


## What for
This stuff build a custom boot cd first, then when you boot that CD, it'll 
install unbuntu 14.04 LTS (trusty) on your hardrive with:

*  Root partition cryptted with dm-crypt
*  An initramfs that let you ssh into in order to unblock the root partition
   during boot

## How

There's 2 stages:

#### Boot CD
This step builds a minimum arch linux boot cd ([archiso](https://wiki.archlinux.org/index.php/Archiso)).


Booted with this CD on the machine/vm that you want to install ubuntu, then 
launch 
```
./install.sh
```
you will have
an ssh shell with root access.

#### Remote install
```
ssh root@your_ip
```
You will wget install scripts from github, format disk,
setup cryptroot, launch debootstrap and install a minimal ubuntu 14.04 LTS,
setup initramfs so that at next boot you can ssh again during boot in order
to unblock the crypted root partition.


