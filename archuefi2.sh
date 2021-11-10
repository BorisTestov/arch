#!/bin/bash

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

echo 'Прописываем имя компьютера'
echo $hostname > /etc/hostname
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

echo '3.4 Добавляем локаль системы'
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

echo 'Обновим текущую локаль системы'
locale-gen

echo 'Указываем язык системы'
echo 'LANG="en_US.UTF-8"' > /etc/locale.conf

echo 'Вписываем KEYMAP=ru FONT=cyr-sun16'
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

echo 'Создадим загрузочный RAM диск'
mkinitcpio -p linux

echo '3.5 Устанавливаем загрузчик'
installyy
install grub efibootmgr 
grub-install /dev/sda

echo 'Обновляем grub.cfg'
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Ставим программу для Wi-fi'
install dialog wpa_supplicant 

echo 'Добавляем пользователя'
useradd -m -g users -G wheel -s /bin/bash $username

echo 'Создаем root пароль'
passwd

echo 'Устанавливаем пароль пользователя'
passwd $username

echo 'Устанавливаем SUDO'
sed -i "s/# %wheel/%wheel/g" /etc/sudoers

echo 'Ставим иксы и драйвера'
install xorg-server xorg-drivers xorg-xinit

echo "Ставим XFCE"
install xfce4 xfce4-goodies

echo 'Ставим шрифты'
install ttf-liberation ttf-dejavu ttf-font-awesome

echo 'Ставим сеть'
install networkmanager network-manager-applet ppp networkmanager-openvpn
systemctl enable NetworkManager
systemctl enable dhcpcd

echo 'Ставим аудио'
install pulseaudio pulseaudio-bluetooth alsa-utils alsa-lib pulseaudio-equalizer-ladspa pavucontrol blueman
systemctl enable bluetooth

echo 'Ставим пакеты для работы с fat / ntfs'
install exfat-utils ntfs-3g

echo 'Установка архиваторов'
install file-roller p7zip unrar unzip unace

echo 'Установка дополнительных пакетов'
install htop spectacle neofetch openssh
systemctl enable sshd 

echo 'Установка AUR (yay) и доппакетов'
aur_install yay
aur_install rtl8812au-dkms-git
aur_install polybar
aur_install ttf-weather-icons
aur_install ttf-clear-sans

echo 'Установка i3'
install i3-wm dmenu 
wget https://github.com/BorisTestov/arch/raw/master/attach/config_i3wm.tar.gz
rm -rf ~/.config/i3/*
rm -rf ~/.config/polybar/*
tar -xzf config_i3wm.tar.gz -C ~/

echo 'Автовход в систему'
cp /etc/X11/xinit/xserverrc ~/.xserverrc
wget https://raw.githubusercontent.com/BorisTestov/arch/master/attach/.xinitrc
mv -f .xinitrc ~/.xinitrc
mkdir /etc/systemd/system/getty@tty1.service.d/
echo -e '[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin' "$username" '--noclear %I $TERM' > /etc/systemd/system/getty@tty1.service.d/override.conf

echo 'Скачивание bashrc'
wget https://raw.githubusercontent.com/BorisTestov/arch/master/attach/.bashrc
rm ~/.bashrc
mv -f .bashrc ~/.bashrc

echo 'Скачивание grub.cfg'
wget https://raw.githubusercontent.com/BorisTestov/arch/master/attach/grub
mv -f grub /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Ставим docker'
install docker
systemctl enable docker
groupadd docker
usermod -aG docker $username

echo 'Ставим discord'
install discord

echo 'Ставим telegram'
install telegram-desktop

echo 'Ставим браузер'
install vivaldi

echo 'Ставим timeshift'
aur_install timeshift

echo 'Установка завершена!'
read -p "Нажмите Enter для перезагруки"
reboot