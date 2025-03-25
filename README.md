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
        Raid Level : raid10   
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

7. 
   
