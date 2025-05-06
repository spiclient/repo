<h1 align="center">ДЗ №7.Работа с загрузчиком.</h1>

## Цель домашнего задания:
+ Научиться попадать в систему без пароля.
+ Устанавливать систему с LVM и переименовывать в VG.
## Программные средства
+ VirtualBox 7.1.6
+ MobaXterm
## Описание домашнего задания:
   + Включить отображение меню Grub.
   + Попасть в систему без пароля несколькими способами.
   + Установить систему с LVM, после чего переименовать VG.

## Выполнение
1. Создаём ВМ под управлением ОС Ubuntu 22.04.
2. Открываем конфигурационный файл **Grub** и находим строки:
   *GRUB_TIMEOUT_STYLE=hidden*    - это параметр в загрузчике GRUB, который скрывает меню загрузки. 
   *GRUB_TIMEOUT=0*               - это параметр показывает задержку в секундах, в течение которого отображается меню выбора GRUB.
   ```
   nano /etc/default/grub
   ```
   >*root@nUbunta2204:~# nano /etc/default/grub*

   Комментируем строку параметра, который отвечает за скрытие меню загрузчика и выставляем задержку в 10 секунд.

   <pre>
     GNU nano 6.2                                       /etc/default/grub
   # If you change this file, run 'update-grub' afterwards to update
   # /boot/grub/grub.cfg.
   # For full documentation of the options in this file, see:
   #   info -f grub -n 'Simple configuration'
   GRUB_DEFAULT=0
   <mark>#GRUB_TIMEOUT_STYLE=hidden
   GRUB_TIMEOUT=10</mark>
   GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
   GRUB_CMDLINE_LINUX_DEFAULT="quiet splash noprompt noshell automatic-ubiquity debian-installer/locale=en_US keyboard-c>
   GRUB_CMDLINE_LINUX=""
   # Uncomment to enable BadRAM filtering, modify to suit your needs
   # This works with Linux (no patch required) and with any kernel that obtains
   # the memory map information from GRUB (GNU Mach, kernel of FreeBSD ...)
   #GRUB_BADRAM="0x01234567,0xfefefefe,0x89abcdef,0xefefefef"
   # Uncomment to disable graphical terminal (grub-pc only)
   #GRUB_TERMINAL=console
   # The resolution used on graphical terminal
   # note that you can use only modes which your graphic card supports via VBE
   # you can see them in real GRUB with the command `vbeinfo'
   #GRUB_GFXMODE=640x480
   # Uncomment if you don't want GRUB to pass "root=UUID=xxx" parameter to Linux
   #GRUB_DISABLE_LINUX_UUID=true
   # Uncomment to disable generation of recovery mode menu entries
   #GRUB_DISABLE_RECOVERY="true"
   # Uncomment to get a beep at grub start
   #GRUB_INIT_TUNE="480 440 1"
   </pre>

3. Обновляем конфигурацию и перезагружаемся.
   ```
   update-grub
   ```
   >*root@nUbunta2204:~# update-grub   
Sourcing file \`/etc/default/grub'   
Sourcing file `/etc/default/grub.d/init-select.cfg'   
Generating grub configuration file ...   
Found linux image: /boot/vmlinuz-6.14.0-061400rc5-generic   
Found initrd image: /boot/initrd.img-6.14.0-061400rc5-generic   
Found linux image: /boot/vmlinuz-5.15.0-134-generic   
Found initrd image: /boot/initrd.img-5.15.0-134-generic   
Warning: os-prober will not be executed to detect other bootable partitions.   
Systems on them will not be added to the GRUB boot configuration.   
Check GRUB_DISABLE_OS_PROBER documentation entry.   
done*
   ```
   reboot
   ```

4. При загрузке системы появится окно загрузчика на 10 секунд.

   ![image](https://github.com/user-attachments/assets/88a61502-bb50-4d3b-be56-8e18f9739a7d)

5. апив

