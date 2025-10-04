#!/bin/bash

function print () {
	echo -e "\033[36m"$@"\e[0m"
}

print 'Настройка языка'
loadkeys ru

print 'Синхронизация системных часов'
timedatectl set-ntp true
timedatectl set-timezone Europe/Nicosia

print 'Создание разделов'
(
	echo d;echo;echo d;echo;echo d;echo;
	
	echo g;

	echo n;echo;echo;echo +512M;echo y;

	echo n;echo;echo;echo +2G;echo y;

	echo n;echo;echo;echo;echo y;

	echo t;echo 1;echo uefi;
	echo t;echo 2;echo swap;
	echo t;echo 3;echo linux;

	echo w;
) | fdisk /dev/nvme0n1

print 'Форматирование дисков'
mkfs.fat -F32 /dev/nvme0n1p1 -I
mkswap /dev/nvme0n1p2 -L swap
mkfs.ext4 /dev/nvme0n1p3 -F -L root

print 'Монтирование дисков'
umount -a
swapoff /dev/nvme0n1p2
mount /dev/nvme0n1p3 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
swapon /dev/nvme0n1p2

print 'Установка основных пакетов'
pacstrap -K /mnt base base-devel dhcpcd linux linux-firmware linux-headers which netctl inetutils neovim git grub efibootmgr inotify-tools timeshift vim networkmanager reflector openssh man sudo


print 'Настройка системы'
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "$(curl -fsSL https://raw.githubusercontent.com/BorisTestov/arch/master/archuefi2.sh)"
umount -a
reboot
