<h1 align="center">ДЗ №5.Работа с NFS</h1>

## Цель домашнего задания:
+ Научиться самостоятельно разворачивать сервис NFS и подключать к нему клиентов.
## Программные средства
+ VirtualBox 7.1.6
+ MobaXterm
## Описание домашнего задания:
   + Основная часть:
     + запустить 2 виртуальных машины (сервер NFS и клиента)
     + на сервере NFS должна быть подготовлена и экспортирована директория
     + в экспортированной директории должна быть поддиректория с именем upload с правами на запись в неё
     + экспортированная директория должна автоматически монтироваться на клиенте при старте виртуальной машины (systemd, autofs или fstab — любым способом)
     + монтирование и работа NFS на клиенте должна быть организована с использованием NFSv3
   + Дополнительно задание:
     + настроить аутентификацию через KERBEROS с использованием NFSv4.
     

## Выполнение
### Основная часть. 
1. Создаём 2 виртуальные машины под управлением ОС Ubuntu 24.04.
####Производим настройки на сервере NFS
2. Устанавливаем NFS
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

3. Проверяем слушащие порты
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
   udp        UNCONN      0            0                              0.0.0.0:111                    0.0.0.0:*                       users:(("rpcbind",pid=1370,fd=5),("systemd",pid=1,fd=125))
   udp        UNCONN      0            0                              0.0.0.0:35380                  0.0.0.0:*                      
   udp        UNCONN      0            0                              0.0.0.0:41584                  0.0.0.0:*                       users:(("rpc.mountd",pid=1943,fd=12))
   udp        UNCONN      0            0                              0.0.0.0:35446                  0.0.0.0:*                       users:(("rpc.mountd",pid=1943,fd=8))
   udp        UNCONN      0            0                              0.0.0.0:43808                  0.0.0.0:*                       users:(("rpc.statd",pid=1930,fd=8))
   udp        UNCONN      0            0                                 [::]:33585                     [::]:*                       users:(("rpc.mountd",pid=1943,fd=6))
   udp        UNCONN      0            0                                 [::]:59409                     [::]:*                       users:(("rpc.mountd",pid=1943,fd=10))
   udp        UNCONN      0            0                                 [::]:111                       [::]:*                       users:(("rpcbind",pid=1370,fd=7),("systemd",pid=1,fd=133))
   udp        UNCONN      0            0                                 [::]:36201                     [::]:*                      
   udp        UNCONN      0            0                                 [::]:40561                     [::]:*                       users:(("rpc.mountd",pid=1943,fd=14))
   udp        UNCONN      0            0                                 [::]:54014                     [::]:*                       users:(("rpc.statd",pid=1930,fd=10))
   tcp        LISTEN      0            4096                     127.0.0.53%lo:53                     0.0.0.0:*                       users:(("systemd-resolve",pid=517,fd=15))
   tcp        LISTEN      0            64                             0.0.0.0:2049                   0.0.0.0:*                      
   tcp        LISTEN      0            4096                           0.0.0.0:111                    0.0.0.0:*                       users:(("rpcbind",pid=1370,fd=4),("systemd",pid=1,fd=124))
   tcp        LISTEN      0            4096                           0.0.0.0:53607                  0.0.0.0:*                       users:(("rpc.mountd",pid=1943,fd=5))
   tcp        LISTEN      0            4096                        127.0.0.54:53                     0.0.0.0:*                       users:(("systemd-resolve",pid=517,fd=17))
   tcp        LISTEN      0            4096                           0.0.0.0:45791                  0.0.0.0:*                       users:(("rpc.mountd",pid=1943,fd=13))
   tcp        LISTEN      0            64                             0.0.0.0:39509                  0.0.0.0:*                      
   tcp        LISTEN      0            4096                           0.0.0.0:36769                  0.0.0.0:*                       users:(("rpc.mountd",pid=1943,fd=9))
   tcp        LISTEN      0            4096                           0.0.0.0:36805                  0.0.0.0:*                       users:(("rpc.statd",pid=1930,fd=9))
   tcp        LISTEN      0            128                          127.0.0.1:6010                   0.0.0.0:*                       users:(("sshd",pid=1041,fd=8))
   tcp        LISTEN      0            4096                              [::]:36065                     [::]:*                       users:(("rpc.mountd",pid=1943,fd=15))
   tcp        LISTEN      0            64                                [::]:2049                      [::]:*                      
   tcp        LISTEN      0            4096                                 *:22                           *:*                       users:(("sshd",pid=965,fd=3),("systemd",pid=1,fd=209))
   tcp        LISTEN      0            4096                              [::]:111                       [::]:*                       users:(("rpcbind",pid=1370,fd=6),("systemd",pid=1,fd=126))
   tcp        LISTEN      0            4096                              [::]:58715                     [::]:*                       users:(("rpc.mountd",pid=1943,fd=11))
   tcp        LISTEN      0            128                              [::1]:6010                      [::]:*                       users:(("sshd",pid=1041,fd=7))
   tcp        LISTEN      0            64                                [::]:44687                     [::]:*                      
   tcp        LISTEN      0            4096                              [::]:37429                     [::]:*                       users:(("rpc.mountd",pid=1943,fd=7))
   tcp        LISTEN      0            4096                              [::]:40753                     [::]:*                       users:(("rpc.statd",pid=1930,fd=11))
   </pre>
4. Создаём папку
   ```
   mkdir -p /srv/share/upload
   ```
   >*root@servernfs:/etc# mkdir -p /srv/share/upload*

5. Устанавливаем права доступа 0775 (пользователь nobody («никто») и группа nogroup («никакая»).
   ```
   chown -R nobody:nogroup /srv/share
   ```
   >*root@servernfs:/etc# chown -R nobody:nogroup /srv/share*

6. Настраиваем доступ к файлу или каталогу
   ```
   chmod 0777 /srv/share/upload
   ```
   >*root@servernfs:/etc# chmod 0777 /srv/share/upload*

7.  Перенаправляем ввод в команду или программу.
    ```
    cat << EOF > /etc/exports 
    /srv/share 192.168.1.39/32(rw,sync,root_squash)
    EOF
    ```
    >*root@servernfs:/etc# cat << EOF > /etc/exports   
/srv/share 192.168.1.39/32(rw,sync,root_squash)   
EOF*

8. Экспортируем библиотеку
   ```
   exportfs -r
   ```
   >*root@servernfs:/etc# exportfs -r
exportfs: /etc/exports [1]: Neither 'subtree_check' or 'no_subtree_check' specified for export "192.168.1.39/32:/srv/share".
  Assuming default behaviour ('no_subtree_check').
  NOTE: this default has changed since nfs-utils version 1.0.x*

9. Проверяем
   ```
   exportfs -s
   ```
   >*root@servernfs:/etc# exportfs -s
/srv/share  192.168.1.39/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)*

#### Производим на стройки на клиенте NFS
10. Устанавливаем
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

11. Добавляем в /etc/fstab строку
    ```
    echo "192.168.1.65:/srv/share/ /mnt nfs vers=3,noauto,x-systemd.automount 0 0" >> /etc/fstab
    ```
    >*root@clientnfs:~# echo "192.168.1.65:/srv/share/ /mnt nfs vers=3,noauto,x-systemd.automount 0 0" >> /etc/fstab*

12. Перезапускаем сервис монтирования
    ```
    systemctl daemon-reload
    ```
    >*root@clientnfs:~# systemctl daemon-reload*

    ```
    systemctl restart remote-fs.target
    ```
    >*root@clientnfs:~# systemctl restart remote-fs.target*

13. Проверяем монтирование
    ```
    mount | grep mnt 
    ```
    >*root@clientnfs:/mnt# mount | grep mnt   
systemd-1 on /mnt type autofs (rw,relatime,fd=69,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=14922)
192.168.1.65:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.1.65,mountvers=3,mountport=41584,mountproto=udp,local_lock=none,addr=192.168.1.65)*


15. ввавв
   
