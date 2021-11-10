#!/bin/bash

function print () {
	echo -e "\033[36m"$@
}

print 'Настройка языка'
loadkeys ru
setfont cyr-sun16

print 'Синхронизация системных часов'
timedatectl set-ntp true

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
) | fdisk /dev/sda

print 'Форматирование дисков'
mkfs.fat -F32 /dev/sda1 -I
mkswap /dev/sda2 -L swap
mkfs.ext4 /dev/sda3 -F -L root

print 'Монтирование дисков'
umount -a
swapoff /dev/sda2
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2
mount /dev/sda3 /mnt

print 'Установка основных пакетов'
pacstrap /mnt base dhcpcd linux linux-headers which netctl inetutils base-devel wget linux-firmware neovim wpa_supplicant

print 'Настройка системы'
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "$(curl -fsSL https://raw.githubusercontent.com/BorisTestov/arch/master/archuefi2.sh)"