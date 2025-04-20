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
   + Определить настройки пула. С помощью команды *zfs import* собрать pool **ZFS**. Командами определить настройки:
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
7. Выводим информацию по созданным пулам.
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

9. Проверяем установленные настройки сжатия на наших пулах.
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

10. Скачиваем один и тот же текстовый файл во все созданные пулы(https://gutenberg.org/cache/epub/2600/pg2600.converter.log).
    ```
    wget -P /poolgzip https://gutenberg.org/cache/epub/2600/pg2600.converter.log
    ```
    >*root@Ubuntu24:~# wget -P /poolgzip https://gutenberg.org/cache/epub/2600/pg2600.converter.log   
--2025-04-19 22:55:11--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log   
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47   
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.   
HTTP request sent, awaiting response... 200 OK   
Length: 41136901 (39M) [text/plain]   
Saving to: ‘/poolgzip/pg2600.converter.log’   
pg2600.converter.log         100%[==============================================>]  39.23M   899KB/s     in 30s   
2025-04-19 22:55:43 (1.30 MB/s) - ‘/poolgzip/pg2600.converter.log’ saved [41136901/41136901]*
    ```
    wget -P /poollz4 https://gutenberg.org/cache/epub/2600/pg2600.converter.log
    ```
    >*root@Ubuntu24:~# wget -P /poollz4 https://gutenberg.org/cache/epub/2600/pg2600.converter.log   
--2025-04-19 22:56:22--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log   
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47   
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.   
HTTP request sent, awaiting response... 200 OK   
Length: 41136901 (39M) [text/plain]   
Saving to: ‘/poollz4/pg2600.converter.log’   
pg2600.converter.log         100%[==============================================>]  39.23M  2.07MB/s    in 24s   
2025-04-19 22:56:47 (1.65 MB/s) - ‘/poollz4/pg2600.converter.log’ saved [41136901/41136901]
    ```
    wget -P /poolzjb https://gutenberg.org/cache/epub/2600/pg2600.converter.log
    ```
    >*root@Ubuntu24:~# wget -P /poolzjb https://gutenberg.org/cache/epub/2600/pg2600.converter.log   
--2025-04-19 22:57:23--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log   
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47   
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.   
HTTP request sent, awaiting response... 200 OK   
Length: 41136901 (39M) [text/plain]   
Saving to: ‘/poolzjb/pg2600.converter.log’   
pg2600.converter.log         100%[==============================================>]  39.23M  2.12MB/s    in 24s   
2025-04-19 22:57:49 (1.62 MB/s) - ‘/poolzjb/pg2600.converter.log’ saved [41136901/41136901]
    ```
    wget -P /poolzle https://gutenberg.org/cache/epub/2600/pg2600.converter.log
    ```
    >*root@Ubuntu24:~# wget -P /poolzle https://gutenberg.org/cache/epub/2600/pg2600.converter.log   
--2025-04-19 22:58:31--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log   
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47   
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.   
HTTP request sent, awaiting response... 200 OK   
Length: 41136901 (39M) [text/plain]   
Saving to: ‘/poolzle/pg2600.converter.log’   
pg2600.converter.log         100%[==============================================>]  39.23M  1.97MB/s    in 25s   
2025-04-19 22:58:56 (1.59 MB/s) - ‘/poolzle/pg2600.converter.log’ saved [41136901/41136901]*   

11. Проверяем наличие файла во всех пулах.
    ```
    ls -l /pool*
    ```
    >*root@Ubuntu24:~# ls -l /pool**   
*/poolgzip:   
total 10966   
-rw-r--r-- 1 root root 41136901 Apr  2 07:31 pg2600.converter.log   
/poollz4:   
total 18008   
-rw-r--r-- 1 root root 41136901 Apr  2 07:31 pg2600.converter.log   
/poolzjb:   
total 22100   
-rw-r--r-- 1 root root 41136901 Apr  2 07:31 pg2600.converter.log   
/poolzle:   
total 40202   
-rw-r--r-- 1 root root 41136901 Apr  2 07:31 pg2600.converter.log*   

12. Сравниваем размер файла и коэффициент компрессии в файловых системах с различными методами сжатия.
    ```
    zfs list
    ```
    >*root@Ubuntu24:~# zfs list*
    <pre>NAME       USED  AVAIL  REFER  MOUNTPOINT   
    <mark>poolgzip  10.9M   341M  10.7M  /poolgzip</mark>        
    poollz4   17.7M   334M  17.6M  /poollz4   
    poolzjb   21.8M   330M  21.6M  /poolzjb   
    poolzle   39.4M   313M  39.3M  /poolzle   
    </pre>
    ```
    zfs get compressratio
    ```
    >*root@Ubuntu24:~# zfs get compressratio*
    <pre>NAME      PROPERTY       VALUE  SOURCE
    <mark>poolgzip  compressratio  3.65x  -</mark>
    poollz4   compressratio  2.23x  -
    poolzjb   compressratio  1.81x  -
    poolzle   compressratio  1.00x  -
    </pre>

#### Наименьший размер и соответственно наибольший коэффициент сжатия имеет файл расположенный в пуле с методом сжатия *gzip-9*

###  Определить основные настройки пула. 
    
13. Скачиваем архив пула по ссылке https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download, а потом разархивируем его.
    ```
    wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'
    ```
    >*root@Ubuntu24:~# wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'   
--2025-04-20 09:54:13--  https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download   
Resolving drive.usercontent.google.com (drive.usercontent.google.com)... 173.194.73.132, 2a00:1450:4010:c1e::84   
Connecting to drive.usercontent.google.com (drive.usercontent.google.com)|173.194.73.132|:443... connected.   
HTTP request sent, awaiting response... 200 OK   
Length: 7275140 (6.9M) [application/octet-stream]   
Saving to: ‘archive.tar.gz’   
archive.tar.gz               100%[==============================================>]   6.94M  8.95MB/s    in 0.8s   
2025-04-20 09:54:22 (8.95 MB/s) - ‘archive.tar.gz’ saved [7275140/7275140]   
    ```
    tar -xzvf archive.tar.gz
    ```
    >*root@Ubuntu24:~# tar -xzvf archive.tar.gz   
      zpoolexport/   
      zpoolexport/filea   
      zpoolexport/fileb*   

14. Проверяем разархивированный каталог на возможность его импорта в пул.
    ```
    zpool import -d zpoolexport/
    ```
    >*root@Ubuntu24:~# zpool import -d zpoolexport/*      
    <pre>pool: otus   
       id: 6554193320433390805   
    state: ONLINE   
    status: Some supported features are not enabled on the pool.   
          (Note that they may be intentionally disabled if the   
          'compatibility' property is set.)   
    action: The pool can be imported using its name or numeric identifier, though   
          some features will not be available without an explicit 'zpool upgrade'.   
    config:   
          otus                         ONLINE   
            mirror-0                   ONLINE   
              /root/zpoolexport/filea  ONLINE   
              /root/zpoolexport/fileb  ONLINE
    </pre>   
#### Полученный вывод сообщает, что данный каталог является экспортируемым пулом Otus.
15. Делаем импорт пула Otus к нам в ОС.
    ```
    zpool import -d zpoolexport/ otus
    ```
    >*root@Ubuntu24:~# zpool import -d zpoolexport/ otus*

    Проверяем статус
    ```
    zpool status otus
    ```
    >*root@Ubuntu24:~# zpool status otus*
    <pre>pool: otus
    state: ONLINE
    status: Some supported and requested features are not enabled on the pool.
              The pool can still be used, but some features are unavailable.
    action: Enable all features using 'zpool upgrade'. Once this is done,
              the pool may no longer be accessible by software that does not support
              the features. See zpool-features(7) for details.
    config:
        NAME                         STATE     READ WRITE CKSUM
        otus                         ONLINE       0     0     0
          mirror-0                   ONLINE       0     0     0
            /root/zpoolexport/filea  ONLINE       0     0     0
            /root/zpoolexport/fileb  ONLINE       0     0     0
    errors: No known data errors
    </pre>

17. Смотрим настройки пула и параметры файловой системы.   

    С помощью команд *zpool get all* и *zfs get all* можно посмотреть сразу все параметры, но нас интересуют только размер    
    хранилища, тип пула, размер блока в файловой системе, коэффициент сжатия и контрольная сумма.

##### Размер хранилища обозначается параметром *"available"*   
    ```
    zfs get available otus
    ```
    >*root@Ubuntu24:~# zfs get available otus   
    NAME  PROPERTY   VALUE  SOURCE   
    otus  available  350M   -*
##### Тип пула обозначается параметром *"type"*   
    ```
    zfs get type otus
    ```
    >*root@Ubuntu24:~# zfs get type otus    
    NAME  PROPERTY  VALUE       SOURCE   
    otus  type      filesystem  -*
    ##### Значение размера блока данных в файловой системе обозначается параметром *"recordsize"*
    ```
    zfs get recordsize otus
    ```
    >*root@Ubuntu24:~# zfs get recordsize otus*
    <pre>NAME  PROPERTY    VALUE    SOURCE
    otus  recordsize  128K     local
    </pre>

##### Коэффициент сжатия обозначается параметром *"compressratio"*
    ```
    zfs get compressratio otus
    ```
    >*root@Ubuntu24:~# zfs get compressratio otus
    <pre>NAME  PROPERTY       VALUE  SOURCE
    otus  compressratio  1.00x  -
    </pre>

##### Тип контрольной суммы обозначается параметром *"type"*
    ```
    zfs get checksum otus
    ```
    >*root@Ubuntu24:~# zfs get checksum otus
    NAME  PROPERTY  VALUE      SOURCE
    otus  checksum  sha256     local
    </pre>
