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
   + Расширить файловую систему за счёт нового диска.
   + Выполнить **resize**
   + Проверить корректность выполнения
   + Уменьшить том под **/** до **8G**.
   + Выделить том под */var* - сделать в mirror.
   + Выделить том под */home*.
   + */home* - сделать том для снапшотов.
   + Прописать монтирование в **fstab**. ~~Попробовать с разными опциями и разными файловыми системами (на выбор).~~
   + Работа со снапшотами:
     + сгенерить файлы в */home/*;
     + снять снапшот;
     + удалить часть файлов;
     + восстановится со снапшота.
   + ~~На дисках попробовать поставить **btrfs/zfs** — с кэшем, снапшотами и разметить там каталог */opt*.~~

Логировать работу можно с помощью утилиты script.
## Выполнение

### Настраиваем LVM и монтируем каталог. 
1. Создаём виртуальную машину под управлением ОС Ubuntu 24.04 в Virtual Box с LVM.
2. Запускаем запись листинга команда в файл **lvm.log**  
   ```
   script lvm.log
   ```
3. Проверяем версию ОС и ядра. 
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
6. Проверяем наличие Physical Volume, Volume Group, Logical Volume.
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

7. Создаём Physical Volume
    ```
    pvcreate /dev/sdb
    ```
    >*root@ubuntu24:~# pvcreate /dev/sdb   
  Physical volume "/dev/sdb" successfully created.*
   
8. Создаём Volume Group
   ```
   vgcreate volgroup /dev/sdb
   ```
   >*root@ubuntu24:~# vgcreate volgroup /dev/sdb   
  Volume group "volgroup" successfully created*

9. Создаём Logical Volume
    ```
    lvcreate -l+80%FREE -n logvol volgroup
    ```
    >*root@ubuntu24:~# lvcreate -l+80%FREE -n logvol volgroup   
  Logical volume "logvol" created.*

10. Проверяем информацию о созданной Logical Volume
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
11. Создаём файловую систему на созданной Logical Volume **logvol**
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
    
12. Создаём каталог **data** и монтируем его  
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

15. аивипвапа

