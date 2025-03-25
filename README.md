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
2. Запускаем систему и смотрим информацию о дисках.
   ```
   ***lsblk***
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

3. Проверяем наличие в системе *raid*-массивов.
   ```
   cat /proc/mdstat
   ```
   >*user@nUbunta2204:~$ cat /proc/mdstat   
Personalities : [linear] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]   
unused devices: <none>*

5. 
