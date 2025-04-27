<h1 align="center">ДЗ №5.Работа с NFS</h1>

## Цель домашнего задания:
+ Научиться самостоятельно разворачивать сервис NFS и подключать к нему клиентов.
## Программные средства
+ VirtualBox 7.1.6
+ MobaXterm
## Описание домашнего задания:
   + Основная часть:
     + запустить 2 виртуальных машины (сервер NFS и клиента)
     + на сервере NFS подготовить и экспортировать директорию
     + в экспортированной директории создать поддиректорию с именем **upload** с правами на запись в неё
     + на экспортированной директории настроить автоматическое монтирование на клиенте при старте виртуальной машины (systemd, autofs или fstab — одним из способов)
     + монтирование и работу с NFS на клиенте организовать с использованием **NFSv3**
     + создаём bash-скрипты для автоматизации развёртывания сервера и клиента NFS
   + Дополнительно задание:
     + настроить аутентификацию через **KERBEROS** с использованием **NFSv4**.
     

## Выполнение
### Основная часть. 
1. Создаём 2 виртуальные машины(ВМ) под управлением ОС Ubuntu 24.04 с именами **severnfs**(IP192.168.1.65) и **clientnfs**(IP192.168.1.39).
   
   При необходимости меняем IP-адреса согласно условию в задании.
   ```
   sudo ip addr add 192.168.1.65/24 dev enp3s0
   ```
   ```
   sudo ip addr add 192.168.1.39/24 dev enp0s3
   ```
   Удаляем старый IP-адрес с помощью команды:
   ```
   sudo ip addr del [IP-address] dev [interface]
   ```
   #### Производим настройки на сервере NFS
2. Устанавливаем компонент для сервера NFS
   ```
   apt install nfs-kernel-server
   ```
   >*root@servernfs:~# apt install nfs-kernel-server   
Reading package lists... Done   
Building dependency tree... Done   
Reading state information... Done       
The following additional packages will be installed:   
  keyutils libnfsidmap1 nfs-common rpcbind   
Suggested packages:   
  watchdog   
The following NEW packages will be installed:   
  keyutils libnfsidmap1 nfs-common nfs-kernel-server rpcbind   
0 upgraded, 5 newly installed, 0 to remove and 59 not upgraded.   
Need to get 569 kB of archives.   
After this operation, 2,022 kB of additional disk space will be used.   
Do you want to continue? [Y/n] y*

3. Проверяем есть ли среди слушащих портов **2049** и **111**
   ```
   ss -tnplu
   ```
   >*root@servernfs:/etc# ss -tnplu*
   <pre>
   Netid      State       Recv-Q       Send-Q                   Local Address:Port              Peer Address:Port                   Process
   udp        UNCONN      0            0                            127.0.0.1:834                    0.0.0.0:*                       users:(("rpc.statd",pid=1930,fd=5))
   udp        UNCONN      0            0                              0.0.0.0:48109                  0.0.0.0:*                       users:(("rpc.mountd",pid=1943,fd=4))
   udp        UNCONN      0            0                           127.0.0.54:53                     0.0.0.0:*                       users:(("systemd-resolve",pid=517,fd=16))
   udp        UNCONN      0            0                        127.0.0.53%lo:53                     0.0.0.0:*                       users:(("systemd-resolve",pid=517,fd=14))
   udp        UNCONN      0            0                  192.168.1.65%enp0s3:68                     0.0.0.0:*                       users:(("systemd-network",pid=508,fd=11))
   <mark>udp        UNCONN      0            0                              0.0.0.0:111                    0.0.0.0:*                       users:(("rpcbind",pid=1370,fd=5),("systemd",pid=1,fd=125))</mark>
   udp        UNCONN      0            0                              0.0.0.0:35380                  0.0.0.0:*                      
   udp        UNCONN      0            0                              0.0.0.0:41584                  0.0.0.0:*                       users:(("rpc.mountd",pid=1943,fd=12))
   udp        UNCONN      0            0                              0.0.0.0:35446                  0.0.0.0:*                       users:(("rpc.mountd",pid=1943,fd=8))
   udp        UNCONN      0            0                              0.0.0.0:43808                  0.0.0.0:*                       users:(("rpc.statd",pid=1930,fd=8))
   udp        UNCONN      0            0                                 [::]:33585                     [::]:*                       users:(("rpc.mountd",pid=1943,fd=6))
   udp        UNCONN      0            0                                 [::]:59409                     [::]:*                       users:(("rpc.mountd",pid=1943,fd=10))
   <mark>udp        UNCONN      0            0                                 [::]:111                       [::]:*                       users:(("rpcbind",pid=1370,fd=7),("systemd",pid=1,fd=133))</mark>
   udp        UNCONN      0            0                                 [::]:36201                     [::]:*                      
   udp        UNCONN      0            0                                 [::]:40561                     [::]:*                       users:(("rpc.mountd",pid=1943,fd=14))
   udp        UNCONN      0            0                                 [::]:54014                     [::]:*                       users:(("rpc.statd",pid=1930,fd=10))
   tcp        LISTEN      0            4096                     127.0.0.53%lo:53                     0.0.0.0:*                       users:(("systemd-resolve",pid=517,fd=15))
   <mark>tcp        LISTEN      0            64                             0.0.0.0:2049                   0.0.0.0:*</mark>                      
   <mark>tcp        LISTEN      0            4096                           0.0.0.0:111                    0.0.0.0:*                       users:(("rpcbind",pid=1370,fd=4),("systemd",pid=1,fd=124))</mark>
   tcp        LISTEN      0            4096                           0.0.0.0:53607                  0.0.0.0:*                       users:(("rpc.mountd",pid=1943,fd=5))
   tcp        LISTEN      0            4096                        127.0.0.54:53                     0.0.0.0:*                       users:(("systemd-resolve",pid=517,fd=17))
   tcp        LISTEN      0            4096                           0.0.0.0:45791                  0.0.0.0:*                       users:(("rpc.mountd",pid=1943,fd=13))
   tcp        LISTEN      0            64                             0.0.0.0:39509                  0.0.0.0:*                      
   tcp        LISTEN      0            4096                           0.0.0.0:36769                  0.0.0.0:*                       users:(("rpc.mountd",pid=1943,fd=9))
   tcp        LISTEN      0            4096                           0.0.0.0:36805                  0.0.0.0:*                       users:(("rpc.statd",pid=1930,fd=9))
   tcp        LISTEN      0            128                          127.0.0.1:6010                   0.0.0.0:*                       users:(("sshd",pid=1041,fd=8))
   tcp        LISTEN      0            4096                              [::]:36065                     [::]:*                       users:(("rpc.mountd",pid=1943,fd=15))
   <mark>tcp        LISTEN      0            64                                [::]:2049                      [::]:*</mark>                      
   tcp        LISTEN      0            4096                                 *:22                           *:*                       users:(("sshd",pid=965,fd=3),("systemd",pid=1,fd=209))
   tcp        LISTEN      0            4096                              [::]:111                       [::]:*                       users:(("rpcbind",pid=1370,fd=6),("systemd",pid=1,fd=126))
   tcp        LISTEN      0            4096                              [::]:58715                     [::]:*                       users:(("rpc.mountd",pid=1943,fd=11))
   tcp        LISTEN      0            128                              [::1]:6010                      [::]:*                       users:(("sshd",pid=1041,fd=7))
   tcp        LISTEN      0            64                                [::]:44687                     [::]:*                      
   tcp        LISTEN      0            4096                              [::]:37429                     [::]:*                       users:(("rpc.mountd",pid=1943,fd=7))
   tcp        LISTEN      0            4096                              [::]:40753                     [::]:*                       users:(("rpc.statd",pid=1930,fd=11))
   </pre>
   
4. Создаём папку **upload**
   ```
   mkdir -p /srv/share/upload
   ```
   >*root@servernfs:/etc# mkdir -p /srv/share/upload*

5. Устанавливаем владельца. Выбираем права доступа **0775** для пользователя *nobody*(«никто») и группы *nogroup*(«никакая»).
   ```
   chown -R nobody:nogroup /srv/share
   ```
   >*root@servernfs:/etc# chown -R nobody:nogroup /srv/share*

6. Настраиваем доступ к каталогу **upload**
   ```
   chmod 0777 /srv/share/upload
   ```
   >*root@servernfs:/etc# chmod 0777 /srv/share/upload*

7.  Добавляем точку монтирования для экспортируемого каталога **upload** в файле **exports**.
    ```
    nano /etc/exports
    ```
    >GNU nano 7.2                                               /etc/exports   
***/srv/share 192.168.1.39(rw,sync,root_squash)***

8. Обновляем список экспортируемых каталогов внесённых в файл **/etc/exports**.  
   ```
   exportfs -r
   ```
   >*root@servernfs:/# exportfs -r
exportfs: /etc/exports [1]: Neither 'subtree_check' or 'no_subtree_check' specified for export "192.168.1.39:/srv/share".
  Assuming default behaviour ('no_subtree_check').
  NOTE: this default has changed since nfs-utils version 1.0.x*

9. Проверяем текущий список экспорта. 
   ```
   exportfs -s
   ```
   >*root@servernfs:/# exportfs -s
/srv/share  192.168.1.39(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
root@servernfs:/#*

   #### Производим настройки на клиенте NFS
10. Устанавливаем компоненты для работы с сетевой файловой системой(NFS) без включения серверных компонентов.
    ```
    sudo apt install nfs-common
    ```
    >*root@clientnfs:~# sudo apt install nfs-common   
Reading package lists... Done   
Building dependency tree... Done   
Reading state information... Done   
The following additional packages will be installed:   
  keyutils libnfsidmap1 rpcbind   
Suggested packages:   
  watchdog   
The following NEW packages will be installed:   
  keyutils libnfsidmap1 nfs-common rpcbind   
0 upgraded, 4 newly installed, 0 to remove and 59 not upgraded.   
Need to get 400 kB of archives.   
After this operation, 1,416 kB of additional disk space will be used.   
Do you want to continue? [Y/n] y*

11. Добавляем в конфигурационный файл **/etc/fstab** точку монтирования, для автоматического монтирования каталога NFS при запуске системы.
    ```
    echo "192.168.1.65:/srv/share/ /mnt nfs vers=3,noauto,x-systemd.automount 0 0" >> /etc/fstab
    ```
    >*root@clientnfs:~# echo "192.168.1.65:/srv/share/ /mnt nfs vers=3,noauto,x-systemd.automount 0 0" >> /etc/fstab*

12. Перезапускаем все файлы служб, обновляем их внутреннюю конфигурацию и перезапускаем сервис монтирования.
    ```
    systemctl daemon-reload
    ```
    >*root@clientnfs:~# systemctl daemon-reload*

    ```
    systemctl restart remote-fs.target
    ```
    >*root@clientnfs:~# systemctl restart remote-fs.target*

13. Проверяем монтирование.
    ```
    mount | grep mnt 
    ```
    >*root@clientnfs:/mnt# mount | grep mnt   
systemd-1 on /mnt type autofs (rw,relatime,fd=69,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=14922)
192.168.1.65:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.1.65,mountvers=3,mountport=41584,mountproto=udp,local_lock=none,addr=192.168.1.65)*
14. Проверка работоспособности настроенного NFS.
    #### На сервере NFS(192.168.1.65)    
    a. Переходим в каталог **/srv/share/upload**     
    b. Создаём тестовый файл **touch check_file**          
    
    ```
    cd /srv/share/upload
    ```
    ```
    touch check_file
    ```
    ```
    ls -l
    ```
    
    >*root@servernfs:/etc# cd /srv/share/upload   
    root@servernfs:/srv/share/upload# touch check_file   
    root@servernfs:/srv/share/upload# ls -l   
    total 0   
    -rw-r--r-- 1 root root 0 Apr 25 21:47 check_file   
    root@servernfs:/srv/share/upload#*

    #### На клиенте NFS(192.168.1.39)     

    a. Переходим в каталог **/mnt/upload**      
    b. Проверяем наличие созданного на сервере файла **check_file**       
    c. Создаём тестовый файл **touch client_file**       
    d. Проверяем, что файл успешно создан       
    
    ```
    cd /mnt/upload
    ```
    ```
    ls -l
    ```
    ```
    touch client_file
    ```
    ```
    ls -l
    ```
    
    >*root@clientnfs:/mnt# cd /mnt/upload   
    root@clientnfs:/mnt/upload# ls -l   
    total 0   
    -rw-r--r-- 1 root root 0 Apr 25 21:47 check_file   
    root@clientnfs:/mnt/upload# touch client_file   
    root@clientnfs:/mnt/upload# ls -l   
    total 0   
    -rw-r--r-- 1 root   root    0 Apr 25 21:47 check_file   
    -rw-r--r-- 1 nobody nogroup 0 Apr 25 21:57 client_file*   

15. Перезагружаем клиент и сервер.
    
    #### Сначала проверяем клиент: 
   
    a.	Переходим в каталог **/mnt/upload**     
    b.	Проверяем наличие ранее созданных файлов       
  
    >*user@clientnfs:~$ cd /mnt/upload   
    user@clientnfs:/mnt/upload$ ls -l   
    total 0   
    -rw-r--r-- 1 root   root    0 Apr 25 21:47 check_file   
    -rw-r--r-- 1 nobody nogroup 0 Apr 25 21:57 client_file   
    user@clientnfs:/mnt/upload$*   

    #### Проверяем сервер:
   
    a. Переходим в каталог **/srv/share/upload/**        
    b. Проверяем экспорты **exportfs -s**      
    с. Смотрим что экспортируется с ВМ **servernfs** с помощью команды *showmount -a 192.168.1.65*           
    >*root@servernfs:~# cd /srv/share/upload/   
    root@servernfs:/srv/share/upload# ls -l    
    total 0   
    -rw-r--r-- 1 root   root    0 Apr 25 21:47 check_file   
    -rw-r--r-- 1 nobody nogroup 0 Apr 25 21:57 client_file   
    root@servernfs:/srv/share/upload# exportfs -s   
    /srv/share  192.168.1.39(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)   
    root@servernfs:/srv/share/upload# showmount -a 192.168.1.65   
    All mount points on 192.168.1.65:   
    192.168.1.39:/srv/share*

    #### Повторно перезагружаем клиент
   
    a. Смотрим что экспортируется с ВМ **servernfs** с помощью команды *showmount -a 192.168.1.65*    
    b. Переходим в каталог **/mnt/upload**           
    c. Проверяем статус монтирования *mount | grep mnt*     
    d. Проверяем наличие ранее созданных файлов    
    e. Создаём тестовый файл **touch final_check**    
      
    >*root@clientnfs: #~showmount -a 192.168.1.65      
    All mount points on 192.168.1.65:   
    root@clientnfs: # cd /mnt/upload   
    root@clientnfs:/mnt/upload# ls -l   
    total 0   
    -rw-r--r-- 1 root   root    0 Apr 25 21:47 check_file   
    -rw-r--r-- 1 nobody nogroup 0 Apr 25 21:57 client_file   
    root@clientnfs:/mnt/upload# mount | grep mnt   
    systemd-1 on /mnt type autofs (rw,relatime,fd=54,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=4053)   
    192.168.1.65:/srv/share/ on /mnt type nfs    (rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.1.65,mountvers    =3,mountport=55311,mountproto=udp,local_lock=none,addr=192.168.1.65)      root@clientnfs:/mnt/upload# touch final_check   
    root@clientnfs:/mnt/upload# ls -l   
    total 0   
    -rw-r--r-- 1 root   root    0 Apr 25 21:47 check_file   
    -rw-r--r-- 1 nobody nogroup 0 Apr 25 21:57 client_file   
    -rw-r--r-- 1 nobody nogroup 0 Apr 25 22:34 final_check*
16. Создаём bash-скрипты.
    
    <u>для сервера</u>
      >**##!/bin/bash   
      apt install nfs-kernel-server   
      mkdir -p /srv/share/upload   
      chown -R nobody:nogroup /srv/share   
      chmod 0777 /srv/share/upload   
      cat << EOF > /etc/exports    
      /srv/share 192.168.1.39(rw,sync,root_squash)   
      EOF   
      exportfs -r**      

22.   Настройка в системе для выполнения скрипта.
    
      **a. в каталоге переменной среды PATH */usr/local/bin* создаём пустой файл.**
      ```
      cd /usr/local/bin
      ```
      ```
      touch script.sh
      ```
      >*root@nUbunta2204:/# cd /usr/local/bin   
        root@nUbunta2204:/usr/local/bin#   
        root@nUbunta2204:/usr/local/bin# touch script.sh   
        root@nUbunta2204:/usr/local/bin#*   
      
      **b. открываем созданный файл редактором nano и копируем в него текст скрипта**.
      ```
      nano script.sh
      ```
      >*root@nUbunta2204:/usr/local/bin# nano script.sh*
      
      **c. делаем файл исполняемым и устанавливаем полные права для владельца, а для остальных пользователей только на чтение и выполнение скрипта.**
      ```
      chmod 755 script.sh
      ```
      >*root@nUbunta2204:/usr/local/bin# chmod 755 script.sh   
        root@nUbunta2204:/usr/local/bin#*
      
      **d. так как скрипт находится в каталоге переменной среды PATH, то его можно запускать по имени из любого места.**

      >*root@nUbunta2204:/# script.sh*
17. лоллпо

   
