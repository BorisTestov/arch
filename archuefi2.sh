#!/bin/bash

function print () {
  echo -e "\033[36m"$@"\e[0m"
}

function aur_install () {
  cd /home/$username
  git clone https://aur.archlinux.org/$1.git
  chown -R $username:users $1
  !!/PKGBUILD
  cd $1
  sudo -u $username makepkg -si --noconfirm
  cd
  rm -rf /home/$username$1
}

function install() {
	instally $@ --noconfirm
}

read -p "Введите имя компьютера: " hostname
read -p "Введите имя пользователя: " username

print 'Прописываем имя компьютера'
echo $hostname > /etc/hostname
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

print 'Добавляем локаль системы'
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

print 'Обновим текущую локаль системы'
locale-gen

print 'Указываем язык системы'
echo 'LANG="en_US.UTF-8"' > /etc/locale.conf

print 'Вписываем KEYMAP=ru FONT=cyr-sun16'
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

print 'Создадим загрузочный RAM диск'
mkinitcpio -p linux

print 'Устанавливаем загрузчик'
installyy
install grub efibootmgr 
grub-install /dev/sda

print 'Обновляем grub.cfg'
grub-mkconfig -o /boot/grub/grub.cfg

print 'Ставим программу для Wi-fi'
install dialog wpa_supplicant 

print 'Добавляем пользователя'
useradd -m -g users -G wheel -s /bin/bash $username

print 'Создаем root пароль'
passwd

print 'Устанавливаем пароль пользователя'
passwd $username

print 'Устанавливаем SUDO'
sed -i "s/# %wheel/%wheel/g" /etc/sudoers

print 'Ставим иксы и драйвера'
install xorg-server xorg-drivers xorg-xinit

print 'Ставим XFCE'
install xfce4 xfce4-goodies

print 'Ставим шрифты'
install ttf-liberation ttf-dejavu ttf-font-awesome

print 'Ставим сеть'
install networkmanager network-manager-applet ppp networkmanager-openvpn
systemctl enable NetworkManager
systemctl enable dhcpcd

print 'Ставим аудио'
install pulseaudio pulseaudio-bluetooth alsa-utils alsa-lib pulseaudio-equalizer-ladspa pavucontrol blueman
systemctl enable bluetooth

print 'Ставим пакеты для работы с fat / ntfs'
install exfat-utils ntfs-3g

print 'Установка архиваторов'
install file-roller p7zip unrar unzip unace

print 'Установка дополнительных пакетов'
install htop spectacle neofetch openssh
systemctl enable sshd 

print 'Установка AUR (yay) и доппакетов'
aur_install yay
aur_install rtl8812au-dkms-git
aur_install polybar
aur_install ttf-weather-icons
aur_install ttf-clear-sans

print 'Установка i3'
install i3-wm dmenu 
wget https://github.com/BorisTestov/arch/raw/master/attach/config_i3wm.tar.gz
rm -rf ~/.config/i3/*
rm -rf ~/.config/polybar/*
tar -xzf config_i3wm.tar.gz -C ~/

print 'Автовход в систему'
cp /etc/X11/xinit/xserverrc ~/.xserverrc
wget https://raw.githubusercontent.com/BorisTestov/arch/master/attach/.xinitrc
mv -f .xinitrc ~/.xinitrc
mkdir /etc/systemd/system/getty@tty1.service.d/
echo -e '[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin' "$username" '--noclear %I $TERM' > /etc/systemd/system/getty@tty1.service.d/override.conf

print 'Скачивание bashrc'
wget https://raw.githubusercontent.com/BorisTestov/arch/master/attach/.bashrc
rm ~/.bashrc
mv -f .bashrc ~/.bashrc

print 'Скачивание grub.cfg'
wget https://raw.githubusercontent.com/BorisTestov/arch/master/attach/grub
mv -f grub /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

print 'Ставим docker'
install docker
systemctl enable docker
groupadd docker
usermod -aG docker $username

print 'Ставим discord'
install discord

print 'Ставим telegram'
install telegram-desktop

print 'Ставим браузер'
install vivaldi

print 'Ставим timeshift'
aur_install timeshift

print 'Установка завершена!'
read -p "Нажмите Enter для перезагруки"
reboot