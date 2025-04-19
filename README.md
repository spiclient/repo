<h1 align="center">ДЗ №4.Работа с ZFS</h1>

## Цель домашнего задания:
+ Научиться самостоятельно устанавливать ZFS, настраивать пулы, изучить основные возможности ZFS.
## Программные средства
+ VirtualBox 7.1.6
+ MobaXterm
## Описание домашнего задания:
   + Определить алгоритм с наилучшим сжатием:
     + определить какие алгоритмы сжатия поддерживает **zfs (gzip, zle, lzjb, lz4)**
     + создать 4 файловых системы на каждой применить свой алгоритм сжатия
     + для сжатия использовать либо текстовый файл, либо группу файлов
   + Определить настройки пула. С помощью команды **zfs import** собрать pool **ZFS**. Командами **zfs** определить настройки:
     + размер хранилища
     + тип **pool**
     + значение **recordsize**
     + какое сжатие используется
     + какая контрольная сумма используется
   + Работа со снапшотами:
     + скопировать файл из удаленной директории
     + восстановить файл локально, **zfs receive**
     + найти зашифрованное сообщение в файле **secret_message**

## Выполнение
### Определить алгоритм с наилучшим сжатием. 
1. Создаём виртуальную машину под управлением ОС Ubuntu 24.04 с 8 дополнительными дисками по 512МБ.
2. Проверяем версию ОС и ядра. 
   ```
   inxi -S    
   ```
   >*user@Ubuntu24:~$ inxi -S  
System:  
  Host: Ubuntu24 Kernel: 6.8.0-57-generic arch: x86_64 bits: 64  
  Desktop: N/A Distro: Ubuntu 24.04.2 LTS (Noble Numbat)<*
3. Выводим информацию о всех блочных устройствах в системе.
   ```
   lsblk     
   ```
   >*user@Ubuntu24:~$ lsblk*  
   <pre>
      NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
      sda                         8:0    0   25G  0 disk
      ├─sda1                      8:1    0    1M  0 part
      ├─sda2                      8:2    0    2G  0 part /boot
      └─sda3                      8:3    0   23G  0 part
        └─ubuntu--vg-ubuntu--lv 252:0    0 11.5G  0 lvm  /
      sdb                         8:16   0  512M  0 disk
      sdc                         8:32   0  512M  0 disk
      sdd                         8:48   0  512M  0 disk
      sde                         8:64   0  512M  0 disk
      sdf                         8:80   0  512M  0 disk
      sdg                         8:96   0  512M  0 disk
      sdh                         8:112  0  512M  0 disk
      sdi                         8:128  0  512M  0 disk
      sr0                        11:0    1 1024M  0 rom
   </pre>
4. Переключаемся в режим суперпользователя.
   ```
   sudo -i
   ```   
5. Устанавливаем утилиты для работы с **zfs**
   ```
   apt install zfsutils-linux
   ```
   >*root@Ubuntu24:~# apt install zfsutils-linux   
Reading package lists... Done   
Building dependency tree... Done   
Reading state information... Done   
The following additional packages will be installed:   
  libnvpair3linux libuutil3linux libzfs4linux libzpool5linux zfs-zed   
Suggested packages:   
  nfs-kernel-server samba-common-bin zfs-initramfs | zfs-dracut   
The following NEW packages will be installed:   
  libnvpair3linux libuutil3linux libzfs4linux libzpool5linux zfs-zed zfsutils-linux   
0 upgraded, 6 newly installed, 0 to remove and 60 not upgraded.   
Need to get 2,355 kB of archives.   
After this operation, 7,399 kB of additional disk space will be used.   
Do you want to continue? [Y/n] y*   
6. Создаём 4 пула из 2х дисков в режиме зеркального RAID.
   ```
   zpool create poollzib mirror /dev/sdb /dev/sdc
   ```
   >*root@Ubuntu24:~# zpool create poollzib mirror /dev/sdb /dev/sdc*
   ```
   zpool create poollz4 mirror /dev/sdd /dev/sde
   ```
   >*root@Ubuntu24:~# zpool create poollz4 mirror /dev/sdd /dev/sde*
   ```
   zpool create poolgzip mirror /dev/sdf /dev/sdg
   ```
   >*root@Ubuntu24:~# zpool create poolgzip mirror /dev/sdf /dev/sdg*
   ```
   zpool create poolzle mirror /dev/sdh /dev/sdi
   ```
   >*root@Ubuntu24:~# zpool create poolzle mirror /dev/sdh /dev/sdi*
7. Проверяем созданные пулы.
   ```
   zpool list
   ```
   >*root@Ubuntu24:~# zpool list*
   <pre>
      NAME       SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
      poolgzip   480M   114K   480M        -         -     0%     0%  1.00x    ONLINE  -
      poollz4    480M   112K   480M        -         -     0%     0%  1.00x    ONLINE  -
      poollzib   480M   114K   480M        -         -     0%     0%  1.00x    ONLINE  -
      poolzle    480M   114K   480M        -         -     0%     0%  1.00x    ONLINE  -
   </pre>
   
8. На каждый пул устанавливаем определенный алгоритм сжатия - **lzjb, lz4, gzip-9, zle**.
   ```
   zfs set compression=lzjb poolzjb
   ```
   >*root@Ubuntu24:~# zfs set compression=lzjb poolzjb*
   ```
   zfs set compression=zle poolzle
   ```
   >*root@Ubuntu24:~# zfs set compression=zle poolzle*
   ```
   zfs set compression=lz4 poollz4
   ```
   >*root@Ubuntu24:~# zfs set compression=lz4 poollz4*
   ```
   zfs set compression=gzip-9 poolgzip
   ```
   >*root@Ubuntu24:~# zfs set compression=gzip-9 poolgzip*

09. Проверяем установленные настройки сжатия на наших пулах.
    ```
    zfs get all | grep compression
    ```
    >*root@Ubuntu24:~# zfs get all | grep compression*
     <pre>
        poolgzip  compression           gzip-9                 local
        poollz4   compression           lz4                    local
        poolzjb   compression           lzjb                   local
        poolzle   compression           zle                    local
     </pre>

11. дрдр
