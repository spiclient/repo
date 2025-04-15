<h1 align="center">ДЗ №3.Файловые системы и LVM</h1>

## Цель домашнего задания:
+ Научиться создавать и управлять логическими томами в LVM.
## Программные средства
+ VirtualBox 7.1.6
+ MobaXterm
## Описание домашнего задания:
   + Настроить LVM в Ubuntu 24.04 Server:
     + создать **Physical Volume**
     + создать **Volume Group**
     + создать **Logical Volume.**
     + отформатировать и смонтировать файловую систему.
   + Расширить файловую систему за счёт нового диска. Выполнить **resize**
   + Проверить корректность выполнения. Разобрать LVM.
   + Уменьшить том под **/** до **8G**.
   + Выделить том под ***/var***. Cделать в **mirror**. Установить автоматическое монтирование в **fstab**.
   + Выделить том под ***/home***. Установить автоматическое монтирование в **fstab**.
   + ***/home*** - сделать том для снапшотов.
   + Работа со снапшотами:
     + сгенерить файлы в ***/home/***;
     + снять снапшот;
     + удалить часть файлов;
     + восстановится со снапшота.
   

Логировать работу можно с помощью утилиты script.
## Выполнение
### Настраиваем LVM и монтируем каталог. 
1. Создаём виртуальную машину под управлением ОС Ubuntu 24.04 в Virtual Box с LVM.
2. Проверяем версию ОС и ядра. 
   ```
   inxi -S     
   ```
   >*user@ubuntu24:~$ inxi -S  
System:  
  Host: ubuntu24 Kernel: 6.8.0-57-generic arch: x86_64 bits: 64  
  Desktop: N/A Distro: Ubuntu 24.04.2 LTS (Noble Numbat)<*
4. Выводим информацию о всех блочных устройствах в системе.
   ```
   lsblk     
   ```
   >*user@ubuntu24:~$ lsblk*  
   <pre>
      NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS  
      sda                         8:0    0   25G  0 disk  
      ├─sda1                      8:1    0    1M  0 part  
      ├─sda2                      8:2    0    2G  0 part /boot  
      └─sda3                      8:3    0   23G  0 part  
        └─ubuntu--vg-ubuntu--lv 252:0    0 11.5G  0 lvm  /  
      sdb                         8:16   0   10G  0 disk  
      sdc                         8:32   0    2G  0 disk  
      sdd                         8:48   0    1G  0 disk  
      sde                         8:64   0    1G  0 disk  
      sr0                        11:0    1 1024M  0 rom  
   </pre>
5. Переключаемся в режим суперпользователя.
   ```
   sudo -i
   ```   
6. Запускаем запись листинга команда в файл **lvm.log**  
   ```
   script lvm.log
   ```
7. Проверяем наличие Physical Volume, Volume Group, Logical Volume.
   ```
   pvs
   ```
   >*root@ubuntu24:~# pvs*   
   <pre>
   PV         VG        Fmt  Attr PSize   PFree   
   /dev/sda3  ubuntu-vg lvm2 a--  <23.00g 11.50g
   </pre>
   ```
   vgs
   ```
   >*root@ubuntu24:~# vgs*   
   <pre>
    VG        #PV #LV #SN Attr   VSize   VFree   
    ubuntu-vg   1   1   0 wz--n- <23.00g 11.50g
   </pre>
   ```
   lvs
   ```
   >*root@ubuntu24:~# lvs*
   <pre>      
    LV        VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync   
    Convert          
    ubuntu-lv ubuntu-vg -wi-ao---- <11.50g
   </pre>

8. Создаём Physical Volume
    ```
    pvcreate /dev/sdb
    ```
    >*root@ubuntu24:~# pvcreate /dev/sdb   
  Physical volume "/dev/sdb" successfully created.*
   
9. Создаём Volume Group
   ```
   vgcreate volgroup /dev/sdb
   ```
   >*root@ubuntu24:~# vgcreate volgroup /dev/sdb   
  Volume group "volgroup" successfully created*

10. Создаём Logical Volume, который использует 80% свободного пространства группы томов.
    ```
    lvcreate -l+80%FREE -n logvol volgroup
    ```
    >*root@ubuntu24:~# lvcreate -l+80%FREE -n logvol volgroup   
  Logical volume "logvol" created.*

11. Проверяем информацию о созданной Logical Volume
    ```
    lvdisplay /dev/volgroup/logvol
    ```
    >*root@ubuntu24:~# lvdisplay /dev/volgroup/logvol*   
    <pre>
          --- Logical volume ---
     LV Path                /dev/volgroup/logvol
     LV Name                logvol
     VG Name                volgroup
     LV UUID                PzbiiG-hFc3-ladP-iKth-GwIH-ZQ4R-t2O2kM
     LV Write Access        read/write
     LV Creation host, time ubuntu24, 2025-04-13 16:25:28 +0000
     LV Status              available
     # open                 0
     LV Size                <8.00 GiB
     Current LE             2047
     Segments               1
     Allocation             inherit
     Read ahead sectors     auto
     - currently set to     256
     Block device           252:1
    </pre>
12. Создаём файловую систему **ext4** на созданной Logical Volume **logvol**
    ```
    mkfs.ext4 /dev/volgroup/logvol
    ```
    >*root@ubuntu24:~# mkfs.ext4 /dev/volgroup/logvol   
mke2fs 1.47.0 (5-Feb-2023)   
Creating filesystem with 2096128 4k blocks and 524288 inodes   
Filesystem UUID: 8340ca6a-c2c9-499d-8c82-4951497961d2   
Superblock backups stored on blocks:   
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632   
Allocating group tables: done   
Writing inode tables: done   
Creating journal (16384 blocks): done   
Writing superblocks and filesystem accounting information: done*   
    
13. Создаём каталог **data** и монтируем его  
    ```
    mkdir /data
    ```
    ```
    mount /dev/volgroup/logvol /data/
    ```
### Расширяем файловую систему с помощью нового диска. 
13. Создаём Physical Volume на новом диске
    ```
    pvcreate /dev/sdc
    ```
14. Расширяем Volume Group новым диском и проверяем.
    ```
    vgextend volgroup /dev/sdc
    ```
    >*root@ubuntu24:~# vgextend volgroup /dev/sdc   
      Volume group "volgroup" successfully extended*
    ```
    vgdisplay -v volgroup | grep 'PV Name'
    ```
    >*root@ubuntu24:~# vgdisplay -v volgroup | grep 'PV Name'   
     PV Name               /dev/sdb   
     PV Name               /dev/sdc*
    ```
    vgs
    ```
    >*root@ubuntu24:~# vgs*
    <pre>
     VG        #PV #LV #SN Attr   VSize   VFree
     ubuntu-vg   1   1   0 wz--n- <23.00g 11.50g
     volgroup    2   1   0 wz--n-  11.99g <4.00g
    </pre>
 
15. Для наглядности имитируем занятое пространство на Logical Volume
    ```
    dd if=/dev/zero of=/data/test.log bs=1M count=10000 status=progress
    ```
    >*root@ubuntu24:~# dd if=/dev/zero of=/data/test.log bs=1M \   
 count=10000 status=progress   
     8167358464 bytes (8.2 GB, 7.6 GiB) copied, 18 s, 452 MB/s   
     dd: error writing '/data/test.log': No space left on device   
     7944+0 records in   
     7943+0 records out   
     8329297920 bytes (8.3 GB, 7.8 GiB) copied, 18.5249 s, 450 MB/s*
    ```
    df -Th /data/
    ```
    >*root@ubuntu24:~# df -Th /data/*
    <pre>
       Filesystem                  Type  Size  Used Avail Use% Mounted on   
       /dev/mapper/volgroup-logvol ext4  7.8G  7.8G     0 100% /data
    </pre>
  
16. Расширяем Logical Volume **logvol**
    ```
    lvextend -l+80%FREE /dev/volgroup/logvol
    ```
    >*root@ubuntu24:~# lvextend -l+80%FREE /dev/volgroup/logvol   
  Size of logical volume volgroup/logvol changed from <8.00 GiB (2047 extents) to <11.20 GiB (2866 extents).   
  Logical volume volgroup/logvol successfully resized.*
    
    ***Проверяем внесенное изменение в размер тома.***
    ```
    lvs
    ```
    >*root@ubuntu24:~# lvs*
    <pre> 
     LV        VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
     ubuntu-lv ubuntu-vg -wi-ao---- <11.50g
     logvol    volgroup  -wi-ao---- <11.20g
     </pre>
     ```
     df -Th /data/
     ```
     >*root@ubuntu24:~# df -Th /data/*   
     <pre>
     Filesystem                  Type  Size  Used Avail Use% Mounted on
     /dev/mapper/volgroup-logvol ext4  7.8G  7.8G     0 100% /data
     </pre>
     ***Со стороны файловой системы изменения не отображаются.***
     ***Выполняем resize***
     ```
     resize2fs /dev/mapper/volgroup-logvol
     ```
     >*root@ubuntu24:~# resize2fs /dev/mapper/volgroup-logvol   
       resize2fs 1.47.0 (5-Feb-2023)    
       Filesystem at /dev/mapper/volgroup-logvol is mounted on /data; on-line resizing required    
       old_desc_blocks = 1, new_desc_blocks = 2    
       The filesystem on /dev/mapper/volgroup-logvol is now 2934784 (4k) blocks long.*
     ```
     df -Th /data/
     ```
     >*root@ubuntu24:~# df -Th /data/*
     <pre>
     Filesystem                  Type  Size  Used Avail Use% Mounted on
     /dev/mapper/volgroup-logvol ext4   11G  7.8G  2.7G  75% /data
     </pre>

### Разбираем LVM. 
17. Размонтируем каталог
    ```
    umount dev/volgroup/logvol /data
    ```
    >*root@ubuntu24:~# umount dev/volgroup/logvol /data   
      umount: dev/volgroup/logvol: no mount point specified.*

18. Удаляем Logical Volume, Volume Group, Physical Volume.
    ```
    lvremove /dev/volgroup/logvol
    ```
    ```
    vgremove /dev/volgroup
    ```
    ```
    pvremove /dev/sdb /dev/sdc
    ```
### Уменьшаем том под **/** до **8G**.    
19. Создаём Physical Volume, Volume Group, Logical Volume.
    ```
    pvcreate /dev/sdb
    ```
    ```
    vgcreate vg_root /dev/sdb
    ```
    ```
    lvcreate -n lv_root -l +100%FREE /dev/vg_root
    ```
20. Создаём файловую систему **ext4** и монтируем каталог */mnt*
    ```
    mkfs.ext4 /dev/vg_root/lv_root
    ```
    >*root@ubuntu24:~# mkfs.ext4 /dev/vg_root/lv_root    
      mke2fs 1.47.0 (5-Feb-2023)    
      Creating filesystem with 2620416 4k blocks and 655360 inodes    
      Filesystem UUID: 76b21f67-0897-4284-a7d7-de0c3e0bbfba   
      Superblock backups stored on blocks:   
      32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632   
      Allocating group tables: done   
      Writing inode tables: done   
      Creating journal (16384 blocks): done   
      Writing superblocks and filesystem accounting information: done*
    ```
    mount /dev/vg_root/lv_root /mnt
    ```
   
21. Копируем все данные из корневого каталога **/** в наш смонтированный каталог.
    ```
    rsync -avxHAX --progress / /mnt/
    ```
    >*root@ubuntu24:~# rsync -avxHAX --progress / /mnt/   
      sending incremental file list    
      ./   
      bin -> usr/bin   
      lib -> usr/lib   
      lib64 -> usr/lib64   
      sbin -> usr/sbin   
      swap.img   
      2,413,821,952 100%  223.02MB/s    0:00:10 (xfr#1, ir-chk=1032/1038)*   
      ***< вывод только начала процесса>***
22. Изменяем корневую директорию и выполняем конфигурацию загрузчика GRUB.
    ```
    for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done   
    ```   
    ```
    chroot /mnt/
    ```
    ```
    grub-mkconfig -o /boot/grub/grub.cfg   
    ```
    ***Обновляем образ initrd.***
    
    ```
    update-initramfs -u
    ```
    
    >*root@ubuntu24:/# update-initramfs -u   
    update-initramfs: Generating /boot/initrd.img-6.8.0-57-generic*

    ***Перезагружаемся и проверяем.***
    ```
    reboot
    ```   


23. Удаляем Logical Volume на котором изначально был корневой каталог **/**
    ```
    lvremove /dev/ubuntu-vg/ubuntu-lv
    ```
    >*root@ubuntu24:~# lvremove /dev/ubuntu-vg/ubuntu-lv   
      Do you really want to remove and DISCARD active logical volume ubuntu-vg/ubuntu-lv? [y/n]: y   
      Logical volume "ubuntu-lv" successfully removed.*
    
24. Создаём новый Logical Volume на 8ГБ.
    ```
    lvcreate -n ubuntu-vg/ubuntu-lv -L 8G /dev/ubuntu-vg
    ```
    >*root@ubuntu24:~# lvcreate -n ubuntu-vg/ubuntu-lv -L 8G /dev/ubuntu-vg   
     WARNING: ext4 signature detected on /dev/ubuntu-vg/ubuntu-lv at offset 1080. Wipe it? [y/n]: y   
     Wiping ext4 signature on /dev/ubuntu-vg/ubuntu-lv.   
     Logical volume "ubuntu-lv" created.*
    ```
    lvs
    ```
    >*root@ubuntu24:~# lvs*   
    <pre>
       LV        VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert   
       ubuntu-lv ubuntu-vg -wi-a-----   8.00g   
       lv_root   vg_root   -wi-ao---- <10.00g   
    </pre>

25. Возвращаем корневой каталог на целевое место. Выполняем *пункты 20. 21. 22*
    ```
    mkfs.ext4 /dev/ubuntu-vg/ubuntu-lv
    ```
    ```
    mount /dev/ubuntu-vg/ubuntu-lv /mnt
    ```
    ```
    rsync -avxHAX --progress / /mnt/
    ```
    ```
    for i in /proc/ /sys/ /dev/ /run/ /boot/; \
    do mount --bind $i /mnt/$i; done
    ```
    ```
    chroot /mnt/
    ```
    ```
    grub-mkconfig -o /boot/grub/grub.cfg
    ```
    ```
    update-initramfs -u
    ```
### Выделить том под */var*. Cделать в mirror. Установить автоматическое монтирование в fstab.    
    
26. Создаём Physical Volume на 2х дисках: sdc, sdd.
    ```
    pvcreate /dev/sdc /dev/sdd
    ```
    >*root@ubuntu24:/# pvcreate /dev/sdc /dev/sdd   
      Physical volume "/dev/sdc" successfully created.   
      Physical volume "/dev/sdd" successfully created.*

27. Создаём Volume Group и Logical Volume.
    ```
    vgcreate vg_var /dev/sdc /dev/sdd
    ```
    ```
    lvcreate -L 950M -m1 -n lv_var vg_var
    ```
28. Создаём на Logical Volume файловую систему **ext4**, монтируем и копируем в неё все данные из каталога **/var**.
    ```
    mkfs.ext4 /dev/vg_var/lv_var
    ```
    >*root@ubuntu24:/# mkfs.ext4 /dev/vg_var/lv_var   
     mke2fs 1.47.0 (5-Feb-2023)   
     Creating filesystem with 243712 4k blocks and 60928 inodes   
     Filesystem UUID: 0410385d-e4e8-4416-82e0-7b5220994762   
     Superblock backups stored on blocks:   
           32768, 98304, 163840, 229376   
     Allocating group tables: done   
     Writing inode tables: done   
     Creating journal (4096 blocks): done   
     Writing superblocks and filesystem accounting information: done*
    ```
    mount /dev/vg_var/lv_var /mnt
    ```
    ```
    cp -aR /var/* /mnt/
    ```
29. Выполняем монтирование **/var**. 
    ```
    umount /mnt
    ```
    ```
    mount /dev/vg_var/lv_var /var
    ```
    
30. Изменяем параметры автоматического монтирования **/var** в fstab.
    ```
    echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
    ```
    ***Перезагружаемся***
    ```
    reboot
    ```

31. Разбираем временную LVM созданную для корневого каталога.
    ```
    lvremove /dev/vg_root/lv_root
    ```
    ```
    vgremove /dev/vg_root
    ```
    ```
    pvremove /dev/sdb
    ```
### Выделить том под */home*. Установить автоматическое монтирование в fstab.  

32. Создаём Logical Volume и файловую систему **ext4** для каталога **/home**. Монтируем.  
    ```
    lvcreate -n lv_home -L 2G /dev/ubuntu-vg
    ```
    ```
    mkfs.ext4 /dev/ubuntu-vg/lv_home
    ```
    ```
    mount /dev/ubuntu-vg/lv_home /mnt/
    ```
33. Копируем содержимое каталога **/home**, а потом его удаляем.

    ```
    cp -aR /home/* /mnt/
    ```
    ```
    rm -rf /home/*
    ```
34. Монтируем новый **/home**.
    ```
    umount /mnt
    ```
    ```
    mount /dev/ubuntu-vg/lv_home /home/
    ```
35. Изменяем параметры автоматического монтирования **/home** в fstab.
    ```
    echo "`blkid | grep Home | awk '{print $2}'` /home ext4 defaults 0 0" >> /etc/fstab
    ```
    
### Работа со снапшотами.
36. Генерируем файлы в каталог **/home**  и убеждаемся в том, что они сгенерироаны.   

    ```
    touch /home/file{1..20}
    ```
    ```
    ls -al /home
    ```
    >*root@Ubuntu24:~# ls -al /home*
    <pre> total 28
      drwxr-xr-x  4 root root  4096 Apr 15 20:49 .
      drwxr-xr-x 24 root root  4096 Apr 15 20:22 ..
      -rw-r--r--  1 root root     0 Apr 15 20:49 file1
      -rw-r--r--  1 root root     0 Apr 15 20:49 file10
      -rw-r--r--  1 root root     0 Apr 15 20:49 file11
      -rw-r--r--  1 root root     0 Apr 15 20:49 file12
      -rw-r--r--  1 root root     0 Apr 15 20:49 file13
      -rw-r--r--  1 root root     0 Apr 15 20:49 file14
      -rw-r--r--  1 root root     0 Apr 15 20:49 file15
      -rw-r--r--  1 root root     0 Apr 15 20:49 file16
      -rw-r--r--  1 root root     0 Apr 15 20:49 file17
      -rw-r--r--  1 root root     0 Apr 15 20:49 file18
      -rw-r--r--  1 root root     0 Apr 15 20:49 file19
      -rw-r--r--  1 root root     0 Apr 15 20:49 file2
      -rw-r--r--  1 root root     0 Apr 15 20:49 file20
      -rw-r--r--  1 root root     0 Apr 15 20:49 file3
      -rw-r--r--  1 root root     0 Apr 15 20:49 file4
      -rw-r--r--  1 root root     0 Apr 15 20:49 file5
      -rw-r--r--  1 root root     0 Apr 15 20:49 file6
      -rw-r--r--  1 root root     0 Apr 15 20:49 file7
      -rw-r--r--  1 root root     0 Apr 15 20:49 file8
      -rw-r--r--  1 root root     0 Apr 15 20:49 file9
      drwx------  2 root root 16384 Apr 15 20:48 lost+found
      drwxr-x---  5 user user  4096 Apr 15 20:46 user
    </pre>
37. Делаем снапшот каталога **/home**.
    ```
    lvcreate -L 100MB -s -n home_snap /dev/ubuntu-vg/LogVol_Home
    ```
38. Удаляем часть данных из **/home**.
    ```
    rm -f /home/file{17..20}
    ```
      
39. Процесс восстановления данных:   
    **a.** *размонтирование каталога **/home***
    ```
    umount /home
    ```
    **b.** *объединение изменения из снапшота в исходный том*
    ```
    lvconvert --merge /dev/ubuntu-vg/home_snap
    ```
    **c.** *монтирование*
    ```
    mount /dev/mapper/ubuntu--vg-lv_home /home
    ```
    **d.** *перезапуск службы с обновленной конфигурацией*
    ```
    systemctl daemon-reload
    ```
    **e.** *проверка*
    ```
    ls -al /home
    ```

