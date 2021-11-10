# Установка 
1) Скачать и записать на флешку ISO образ Arch Linux https://www.archlinux.org/download/

2) Скачать и запустить скрипт командой:
   
   ```bash
   curl -OL https://raw.githubusercontent.com/BorisTestov/arch/master/archuefi1.sh && sh archuefi1.sh
   ```
   Запустится установка минимальной системы.
   2-я часть ставится автоматически и это базовая установка ArchLinux без программ. 

3) Установить дополнительные программы, AUR (yay), конфиги XFCE/i3wm.
   Установка 3-й части производится из терминала командой:
   
   ```bash 
   curl -OL https://raw.githubusercontent.com/BorisTestov/arch/master/archuefi3.sh && sh archuefi3.sh
   ```