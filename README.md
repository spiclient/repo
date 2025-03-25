<h1 align="center">ДЗ №2.Управление программными<br>RAID-массивами с помощью mdadm</h1>

## Цель домашнего задания:
+ Научиться использовать утилиту ***mdadm*** для управления программными RAID-массивами в Linux.
## Программные средства
+ VirtualBox 7.1.6
+ MobaXterm
## Описание домашнего задания:
   + Добавить в виртуальную машину несколько дисков.
   + Собрать RAID-0/1/5/10.
   + Сломать и починить RAID.
   + Создать GPT таблицу, пять разделов и смонтировать их в системе.
## Выполнение
1. Создаём и добавляем в виртуальную машину в Virtual Box 6 жестких дисков объёмом **2ГБ**.
2. Запускаем систему и смотрим информацию о дисках с помощью команд **lsblk** и **lshw**.
   ```
   lsblk
   ```
   >*user@nUbunta2204:~$ lsblk   
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS      
loop0    7:0    0 63.9M  1 loop /snap/core20/2318   
loop1    7:1    0 63.7M  1 loop /snap/core20/2496   
loop2    7:2    0   87M  1 loop /snap/lxd/29351   
loop3    7:3    0 89.4M  1 loop /snap/lxd/31333   
loop4    7:4    0 38.8M  1 loop /snap/snapd/21759   
loop5    7:5    0 44.4M  1 loop /snap/snapd/23545   
sda      8:0    0   25G  0 disk   
├─sda1   8:1    0    1M  0 part   
└─sda2   8:2    0   25G  0 part /   
sdb      8:16   0    2G  0 disk   
sdc      8:32   0    2G  0 disk   
sdd      8:48   0    2G  0 disk   
sde      8:64   0    2G  0 disk   
sdf      8:80   0    2G  0 disk   
sdg      8:96   0    2G  0 disk*   
   ```
   lshw -short | grep disk
   ```
   >*user@nUbunta2204:~$ sudo lshw -short | grep disk   
   [sudo] password for user:   
   /0/100/d/0      /dev/sda   disk        26GB VBOX HARDDISK   
   /0/100/d/1      /dev/sdb   disk        2147MB VBOX HARDDISK   
   /0/100/d/2      /dev/sdc   disk        2147MB VBOX HARDDISK   
   /0/100/d/3      /dev/sdd   disk        2147MB VBOX HARDDISK   
   /0/100/d/4      /dev/sde   disk        2147MB VBOX HARDDISK   
   /0/100/d/5      /dev/sdf   disk        2147MB VBOX HARDDISK   
   /0/100/d/0.0.0  /dev/sdg   disk        2147MB VBOX HARDDISK*

3. Проверяем наличие в системе *raid*-массивов или их отсутствие.
   ```
   cat /proc/mdstat
   ```
   >*user@nUbunta2204:~$ cat /proc/mdstat   
Personalities : [linear] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]   
unused devices: <none>*

4. Выполняем "зануление суперблоков"(удаление метаданных, связанных с предыдущими конфигурациями RAID).
   ```
   mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}
   ```
   >*user@nUbunta2204:~$ sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}   
[sudo] password for user:   
mdadm: Unrecognised md component device - /dev/sdb   
mdadm: Unrecognised md component device - /dev/sdc   
mdadm: Unrecognised md component device - /dev/sdd   
mdadm: Unrecognised md component device - /dev/sde   
mdadm: Unrecognised md component device - /dev/sdf   
mdadm: Unrecognised md component device - /dev/sdg*
   
5. Создаём *raid*-массив **RAID10** из 6 дисков.
   ```
   mdadm --create --verbose /dev/md0 -l 10 -n 6 /dev/sd{b,c,d,e,f,g}
   ```
   >*user@nUbunta2204:~$ sudo mdadm --create --verbose /dev/md0 -l 10 -n 6 /dev/sd{b,c,d,e,f,g}   
mdadm: layout defaults to n2   
mdadm: layout defaults to n2   
mdadm: chunk size defaults to 512K   
mdadm: size set to 2094080K   
mdadm: Defaulting to version 1.2 metadata   
mdadm: array /dev/md0 started*.   

6. Проверяем результат.
   ```
   cat /proc/mdstat
   ```
   >*user@nUbunta2204:~$ cat /proc/mdstat   
Personalities : [linear] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]   
md0 : __active raid10__ sdg[5] sdf[4] sde[3] sdd[2] sdc[1] sdb[0]   
      6282240 blocks super 1.2 512K chunks 2 near-copies [6/6] [UUUUUU]   
unused devices: <none>*
   ```
   mdadm -D /dev/md0
   ```
   >*user@nUbunta2204:~$ sudo mdadm -D /dev/md0   
[sudo] password for user:   
/dev/md0:   
           Version : 1.2   
     Creation Time : Tue Mar 25 21:01:01 2025   
        Raid Level : **raid10**   
        Array Size : 6282240 (5.99 GiB 6.43 GB)   
     Used Dev Size : 2094080 (2045.00 MiB 2144.34 MB)   
      Raid Devices : 6   
     Total Devices : 6   
       Persistence : Superblock is persistent   
       Update Time : Tue Mar 25 21:01:35 2025   
             State : clean   
    Active Devices : 6   
   Working Devices : 6   
    Failed Devices : 0   
     Spare Devices : 0   
            Layout : near=2   
        Chunk Size : 512K   
Consistency Policy : resync   
              Name : nUbunta2204:0  (local to host nUbunta2204)   
              UUID : f6307bfb:75b4a060:4172a3ae:d9a17e9a   
            Events : 17   
    Number   Major   Minor   RaidDevice State   
       0       8       16        0      active sync set-A   /dev/sdb   
       1       8       32        1      active sync set-B   /dev/sdc   
       2       8       48        2      active sync set-A   /dev/sdd   
       3       8       64        3      active sync set-B   /dev/sde   
       4       8       80        4      active sync set-A   /dev/sdf   
       5       8       96        5      active sync set-B   /dev/sdg*  

7. Переводим один из дисков в состояние *fail*
   ```
   mdadm /dev/md0 --fail /dev/sde
   ```
   >*user@nUbunta2204:~$ sudo mdadm /dev/md0 --fail /dev/sde   
[sudo] password for user:   
mdadm: set /dev/sde faulty in /dev/md0*

8. Проверяем состояние *raid*-массива.
   ```
   cat /proc/mdstat
   ```
   >*user@nUbunta2204:~$ cat /proc/mdstat   
Personalities : [linear] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]   
md0 : active raid10 sdg[5] sdf[4] **sde[3] (F)** sdd[2] sdc[1] sdb[0]   
      6282240 blocks super 1.2 512K chunks 2 near-copies [6/5] [UUU_UU]   
unused devices: <none>*
   ```
   mdadm -D /dev/md0
   ```
   >*user@nUbunta2204:~$ sudo mdadm -D /dev/md0   
/dev/md0:   
           Version : 1.2   
     Creation Time : Tue Mar 25 21:01:01 2025   
        Raid Level : raid10   
        Array Size : 6282240 (5.99 GiB 6.43 GB)   
     Used Dev Size : 2094080 (2045.00 MiB 2144.34 MB)   
      Raid Devices : 6   
     Total Devices : 6   
       Persistence : Superblock is persistent   
       Update Time : Tue Mar 25 21:44:52 2025   
             **State : clean, degraded**   
    Active Devices : 5   
   Working Devices : 5   
    Failed Devices : 1   
     Spare Devices : 0   
            Layout : near=2   
        Chunk Size : 512K   
Consistency Policy : resync   
              Name : nUbunta2204:0  (local to host nUbunta2204)   
              UUID : f6307bfb:75b4a060:4172a3ae:d9a17e9a   
            Events : 19   
    Number   Major   Minor   RaidDevice State   
       0       8       16        0      active sync set-A   /dev/sdb   
       1       8       32        1      active sync set-B   /dev/sdc   
       2       8       48        2      active sync set-A   /dev/sdd   
    ***-       0        0        3      removed***   
       4       8       80        4      active sync set-A   /dev/sdf   
       5       8       96        5      active sync set-B   /dev/sdg   
       3       8       64        -      faulty   /dev/sde*   
   
09. Удаляем сбойный диск из *raid*-массива.
    ```
    mdadm /dev/md0 --remove /dev/sde
    ```
    >*user@nUbunta2204:~$ sudo mdadm /dev/md0 --remove /dev/sde   
mdadm: hot removed /dev/sde from /dev/md0*   

10. После замены диска, добавляем новый в *raid*-массив.
    ```
    mdadm /dev/md0 --add /dev/sde
    ```
    >*user@nUbunta2204:~$ sudo mdadm /dev/md0 --add /dev/sde   
mdadm: added /dev/sde*

11. Проверяем состояние *raid*-массива.
    ```
    cat /proc/mdstat
    ```
    >*user@nUbunta2204:~$ cat /proc/mdstat   
Personalities : [linear] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]   
md0 : active raid10 **sde[6]** sdg[5] sdf[4] sdd[2] sdc[1] sdb[0]   
      6282240 blocks super 1.2 512K chunks 2 near-copies [6/6] [UUUUUU]   
unused devices: <none>*
    ```
    mdadm -D /dev/md0
    ```
    >*user@nUbunta2204:~$ sudo mdadm -D /dev/md0   
/dev/md0:   
           Version : 1.2   
     Creation Time : Tue Mar 25 21:01:01 2025   
        Raid Level : raid10   
        Array Size : 6282240 (5.99 GiB 6.43 GB)   
     Used Dev Size : 2094080 (2045.00 MiB 2144.34 MB)   
      Raid Devices : 6   
     Total Devices : 6   
       Persistence : Superblock is persistent   
       Update Time : Tue Mar 25 22:03:54 2025   
             State : clean   
    Active Devices : 6   
   Working Devices : 6   
    Failed Devices : 0   
     Spare Devices : 0   
            Layout : near=2   
        Chunk Size : 512K   
Consistency Policy : resync   
              Name : nUbunta2204:0  (local to host nUbunta2204)   
              UUID : f6307bfb:75b4a060:4172a3ae:d9a17e9a   
            Events : 39   
    Number   Major   Minor   RaidDevice State   
       0       8       16        0      active sync set-A   /dev/sdb   
       1       8       32        1      active sync set-B   /dev/sdc   
       2       8       48        2      active sync set-A   /dev/sdd   
       6       8       64        3      active sync set-B   /dev/sde   
       4       8       80        4      active sync set-A   /dev/sdf   
       5       8       96        5      active sync set-B   /dev/sdg*   

12. Создаём папки **d01, d02,d03,d04,d05** в каталоге */mnt/* для монтирования.
    ```
    mkdir d01
    ```
    >*user@nUbunta2204:/$ cd /mnt/      
    user@nUbunta2204:/mnt$ mkdir d01   
    user@nUbunta2204:/mnt$ mkdir d02   
    user@nUbunta2204:/mnt$ mkdir d03   
    >user@nUbunta2204:/mnt$ mkdir d04   
    >user@nUbunta2204:/mnt$ mkdir d05*      

13. Создаём на *raid*-массиве файловую систему **XFS**
    ```
    mkfs.xfs -f /dev/md0
    ```
    >*user@nUbunta2204:/$ sudo mkfs.xfs -f /dev/md0   
log stripe unit (524288 bytes) is too large (maximum is 256KiB)   
log stripe unit adjusted to 32KiB   
meta-data=/dev/md0               isize=512    agcount=8, agsize=196352 blks   
         =                       sectsz=512   attr=2, projid32bit=1   
         =                       crc=1        finobt=1, sparse=1, rmapbt=0   
         =                       reflink=1    bigtime=0 inobtcount=0   
data     =                       bsize=4096   blocks=1570560, imaxpct=25   
         =                       sunit=128    swidth=384 blks   
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1   
log      =internal log           bsize=4096   blocks=2560, version=2   
         =                       sectsz=512   sunit=8 blks, lazy-count=1   
realtime =none                   extsz=4096   blocks=0, rtextents=0*
       
14. Выполняем монтирование к каталогу */mnt/d01/*
    ```
    mount /dev/md0 /mnt/d01
    ```
    >*user@nUbunta2204:/$ sudo mount /dev/md0 /mnt/d01   
user@nUbunta2204:/$*

15. Проверяем успешность выполненных действий.
    ```
    df -hT
    ```
    <pre>*user@nUbunta2204:/$ df -hT   
Filesystem   Type   Size  Used Avail Use% Mounted on   
tmpfs        tmpfs  197M  1.1M  196M   1% /run   
/dev/sda2    ext4    25G  4.2G   20G  18% /   
tmpfs        tmpfs  985M     0  985M   0% /dev/shm   
tmpfs        tmpfs  5.0M     0  5.0M   0% /run/lock   
tmpfs        tmpfs  197M  4.0K  197M   1% /run/user/1000   
**/dev/md0     xfs    6.0G   76M  6.0G   2% /mnt/d01***  
</pre>
17. ываыва
   
