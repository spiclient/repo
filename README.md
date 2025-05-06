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
1. Создаём ВМ под управлением ОС Ubuntu 24.04 с LVM.   
   #### Включение меню загрузчика.   
2. Открываем конфигурационный файл **Grub** с правами суперпользователя и находим строки:   
   *GRUB_TIMEOUT_STYLE=hidden*    - это параметр в загрузчике GRUB, который скрывает меню загрузки.      
   *GRUB_TIMEOUT=0*               - это параметр показывает задержку в секундах, в течение которого отображается меню выбора GRUB.    
   ```
   nano /etc/default/grub
   ```
   >*root@nubuntu2404:~# nano /etc/default/grub*

   Комментируем строку параметра, который отвечает за скрытие меню загрузчика и выставляем задержку в 10 секунд.

   <pre>
          GNU nano 7.2                            /etc/default/grub   
   # If you change this file, run 'update-grub' afterwards to update   
   # /boot/grub/grub.cfg.   
   # For full documentation of the options in this file, see:   
   #   info -f grub -n 'Simple configuration'   
   GRUB_DEFAULT=0   
   <mark>#GRUB_TIMEOUT_STYLE=hidden   
   GRUB_TIMEOUT=10</mark>   
   GRUB_DISTRIBUTOR=`( . /etc/os-release; echo ${NAME:-Ubuntu} ) 2>/dev/null || echo   Ubuntu`   
   GRUB_CMDLINE_LINUX_DEFAULT=""   
   GRUB_CMDLINE_LINUX=""   
   # If your computer has multiple operating systems installed, then you   
   # probably want to run os-prober. However, if your computer is a host   
   # for guest OSes installed via LVM or raw disk devices, running   
   # os-prober can cause damage to those guest OSes as it mounts   
   # filesystems to look for things.   
   #GRUB_DISABLE_OS_PROBER=false   
   # Uncomment to enable BadRAM filtering, modify to suit your needs   
   # This works with Linux (no patch required) and with any kernel that obtains   
   # the memory map information from GRUB (GNU Mach, kernel of FreeBSD ...)   
   #GRUB_BADRAM="0x01234567,0xfefefefe,0x89abcdef,0xefefefef"   
   # Uncomment to disable graphical terminal    
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
   >*root@nubuntu2404:~# update-grub   
Sourcing file `/etc/default/grub'   
Generating grub configuration file ...   
Found linux image: /boot/vmlinuz-6.8.0-59-generic    
Found initrd image: /boot/initrd.img-6.8.0-59-generic    
Warning: os-prober will not be executed to detect other bootable partitions.   
Systems on them will not be added to the GRUB boot configuration.    
Check GRUB_DISABLE_OS_PROBER documentation entry.   
Adding boot menu entry for UEFI Firmware Settings ...   
done*
   ```
   reboot
   ```

4. При загрузке системы появится окно загрузчика на 10 секунд.

   ![image](https://github.com/user-attachments/assets/460a5aad-d567-4e5c-aae1-cab30837c07d)


   #### Запуск системы без ввода пароля.
5. **Вариант 1**. Редактируем параметры загрузки, добавляем опцию *init=/bin/bash* в конец строки Linux.
   a. На экране меню загрузчика **Grub** нажимаем клавишу *E*, находим искомую строку и добавляем новый параметр.
   
   ![image](https://github.com/user-attachments/assets/200c43a9-5870-48c6-b86f-2edd59fca746)
   
   b. Нажимаем **Ctrl-X** - перезагружаемся и получаем доступ к корневой оболочке под правами суперпользователя.

   ![image](https://github.com/user-attachments/assets/b686cede-3a9b-4d85-bdd7-bd1162382edf)

   c. Но система монтируется в режиме *Read-Only*, убеждаемся в этом.
   ```
   mount | grep -w /
   ```
   >*root@(none):/# mount | grep -w /
   /dev/mapper/ubuntu--vg-ubuntu--lv on / type ext4 (ro,relatime)*

   d. Перемонтируем систему в режим *Read-Write*.   
   ```
   mount -o remount, rw /
   ```
   >*root@(none):/# mount -o remount, rw /    
   [3310.109849] EXT4-fs (dm-0): re-mounted 59db6a17-25be-4e0d-91ec-158ee5725aba r/w. Quota mode: none.*

   e. Проверяем изменение прав на *Read-Write*.
   ```
   mount | grep -w /
   ```
   >*root@(none):/# mount | grep -w /
   /dev/mapper/ubuntu--vg-ubuntu--lv on / type ext4 (rw,relatime)*
  
6. **Вариант 2**. Recovery mode.
   a. На экране меню загрузчика **Grub** выбираем **Advanced options for Ubuntu**.
   
   ![image](https://github.com/user-attachments/assets/460a5aad-d567-4e5c-aae1-cab30837c07d)

   b. Далее, пункт меню с указанием **Recovery mode** в названии.
    
   ![image](https://github.com/user-attachments/assets/c6b95565-1c4e-4a79-8a80-e1cae7798898)

   c. В открывшемся меню режима восстановления включаем поддержку сети(network), выбираем пункт *root* и попадаем в консоль управления.
      Вводим пароль **root** если он был задан.
   
      ![image](https://github.com/user-attachments/assets/0c472b17-9a05-4725-9f66-dbc34a7e2222)

   #### Переименование Volume Group на LVM.
   
7. Наша система Ubuntu 24.04 развернута со стандартной разметкой диска с использованием LVM.
   
   a. Смотрим список **Volume Group** в системе.
       
   ```
   vgs
   ```
   >*root@nubuntu2404:~# vgs
  VG        #PV #LV #SN Attr   VSize   VFree
  ubuntu-vg   1   1   0 wz--n- <23.00g 11.50g*   

   b. Приступаем к переименованию группы.    

   ```
   vgrename ubuntu-vg ubuntu-otus

   ```
   >*root@nubuntu2404:~# vgrename ubuntu-vg ubuntu-otus       
  Volume group "ubuntu-vg" successfully renamed to "ubuntu-otus"*
      
   c. Далее, меняем название **Volume Group** в файле **grub.cfg** настроек загрузчика Grub.   
   ```
   nano /boot/grub/grub.cfg
   ```
   >*root@nubuntu2404:~# nano /boot/grub/grub.cfg*      
   <pre>
      <mark>linux   /vmlinuz-6.8.0-59-generic root=/dev/mapper/ubuntu--otus-ubuntu--lv ro 
        initrd  /initrd.img-6.8.0-59-generic</mark>
}
submenu 'Advanced options for Ubuntu' $menuentry_id_option 'gnulinux-advanced-59db6a17-25be-4e0d-91ec-158ee5725aba' {
        menuentry 'Ubuntu, with Linux 6.8.0-59-generic' --class ubuntu --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-6.8.0->
                recordfail
                load_video
                gfxmode $linux_gfx_mode
                insmod gzio
                if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
                insmod part_gpt
                insmod ext2
                set root='hd0,gpt2'
                if [ x$feature_platform_search_hint = xy ]; then
                  search --no-floppy --fs-uuid --set=root --hint-bios=hd0,gpt2 --hint-efi=hd0,gpt2 --hint-baremetal=ahci0,gpt2  b948ca5d-fc6e-4899-88>
                else
                  search --no-floppy --fs-uuid --set=root b948ca5d-fc6e-4899-88a9-7da372014cb8
                fi
                echo    'Loading Linux 6.8.0-59-generic ...'
                <mark>linux   /vmlinuz-6.8.0-59-generic root=/dev/mapper/ubuntu--otus-ubuntu--lv ro</mark>
                echo    'Loading initial ramdisk ...'
                initrd  /initrd.img-6.8.0-59-generic
        }
        menuentry 'Ubuntu, with Linux 6.8.0-59-generic (recovery mode)' --class ubuntu --class gnu-linux --class gnu --class os $menuentry_id_option >
                recordfail
                load_video
                insmod gzio
                if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
                insmod part_gpt
                insmod ext2
                set root='hd0,gpt2'
                if [ x$feature_platform_search_hint = xy ]; then
                  search --no-floppy --fs-uuid --set=root --hint-bios=hd0,gpt2 --hint-efi=hd0,gpt2 --hint-baremetal=ahci0,gpt2  b948ca5d-fc6e-4899-88>
                else
                  search --no-floppy --fs-uuid --set=root b948ca5d-fc6e-4899-88a9-7da372014cb8
                fi
                echo    'Loading Linux 6.8.0-59-generic ...'
                <mark>linux   /vmlinuz-6.8.0-59-generic root=/dev/mapper/ubuntu--otus-ubuntu--lv ro recovery nomodeset dis_ucode_ldr</mark>
                echo    'Loading initial ramdisk ...'
                initrd  /initrd.img-6.8.0-59-generic
        }
}


   </pre>
### END /etc/grub.d/10_linux ###



9. 
