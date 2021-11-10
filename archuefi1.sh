#!/bin/bash

# Arch Linux Fast Install - Быстрая установка Arch Linux https://github.com/ordanax/arch
# Цель скрипта - быстрое развертывание системы с вашими персональными настройками (конфиг XFCE, темы, программы и т.д.).
# Автор скрипта Алексей Бойко https://vk.com/ordanax


loadkeys ru
setfont cyr-sun16
echo 'Скрипт сделан на основе чеклиста Бойко Алексея по Установке ArchLinux'
echo 'Ссылка на чек лист есть в группе vk.com/arch4u'

echo '2.3 Синхронизация системных часов'
timedatectl set-ntp true

echo '2.4 создание разделов'
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

echo 'Ваша разметка диска'
fdisk -l

echo '2.4.2 Форматирование дисков'

mkfs.fat -F32 /dev/sda1 -L uefi
mkswap /dev/sda2 -L swap
mkfs.ext4 /dev/sda3 -L root

echo '2.4.3 Монтирование дисков'
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2
mount /dev/sda3 /mnt

echo '3.1 Обновление зеркал для загрузки.'
pacman -Sy reflector --noconfirm
reflector --verbose -l 50 --sort rate --save /etc/pacman.d/mirrorlist

echo '3.2 Установка основных пакетов'
pacstrap /mnt base dhcpcd linux linux-headers which netctl inetutils base-devel wget linux-firmware neovim wpa_supplicant

echo '3.3 Настройка системы'
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "$(curl -fsSL https://raw.githubusercontent.com/BorisTestov/arch/master/archuefi2.sh)"