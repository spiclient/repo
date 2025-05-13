<h1 align="center">ДЗ №8.Systemd - создание unit-файла.</h1>

## Цель домашнего задания:
+ Научиться редактировать существующие и создавать новые unit-файлы.
## Программные средства
+ VirtualBox 7.1.6
+ MobaXterm
## Описание домашнего задания:
   + Развернуть виртуальную машину с включенной Nested Virtualization.
   + Написать *service*, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в */etc/default*).
   + Установить **spawn-fcgi** и создать **unit**-файл (**spawn-fcgi.sevice**) с помощью переделки **init**-скрипта (***https://gist.github.com/cea2k/1318020***).
   + Доработать **unit**-файл Nginx (**nginx.service**) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно.

## Выполнение
1. Создаём ВМ под управлением ОС Ubuntu 24.04 с включенной Nested Virtualization.   
   Включаем вложенную виртуализацию, если VirtualBox установлен под Windows.   
   **a.** запускаем PowerShell от имени администратора       
   **b.** выводим список ВМ      
      ```
      VBoxManage list vms
      ```
      >*PS C:\WINDOWS\system32> VBoxManage list vms   
"nUbunta2404" {9a4944e1-f09c-466e-973d-bbc303b9fc7a}*   
      
   **c.** включаем вложенную виртуализацию(ВМ должна быть выключена)    
      ```
      VBoxManage.exe modifyvm "nUbunta2404" --nested-hw-virt on
      ```
      >*PS C:\WINDOWS\system32> VBoxManage.exe modifyvm "nUbunta2404" --nested-hw-virt on*
      
   ### Написать service по поиску слова в файле лога.

2. Cоздаём файл в директории */etc/default* с указанной конфигурацией для сервиса.
   ```
   cat << EOF >> /etc/default/watchlog
   WORD="ALERT"
   LOG=/var/log/watchlog.log
   EOF
   ```
   >*root@nubuntu2404:/# cat << EOF >> /etc/default/watchlog   
   #Configuration file for my watchlog service    
   #Place it to /etc/default    
   #File and word in that file that we will be monit    
   WORD="ALERT"    
   LOG=/var/log/watchlog.log    
   EOF*
3. Создаём файл лога **watchlog.log** со своими строками, в котором и будем осуществлять поиск по ключевому слову **Alert**.
   ```
   cat << EOF >> /var/log/watchlog.log    
   trigger 1
   trigger 2
   ALERT
   STOP SERVICE
   zabbix
   EOF
   ```
   >*root@nubuntu2404:/# cat << EOF >> /var/log/watchlog.log       
   trigger 1   
   trigger 2    
   ALERT   
   STOP SERVICE   
   zabbix   
   EOF*   
4. Создаём скрипт.
   ```
   touch /opt/watchlog.sh && nano /opt/watchlog.sh
   ```
   >*root@nubuntu2404:/# touch /opt/watchlog.sh && nano /opt/watchlog.sh*
   <pre>
     GNU nano 7.2                                                       watchlog.sh
   #!/bin/bash
   WORD=$1
   LOG=$2
   DATE=`date`
   if grep $WORD $LOG &> /dev/null
   then
   logger "$DATE: I found word, Master!"
   else
   exit 0
   fi
   </pre>


5. Добавляем права на запуск скрипта.
   ```
   chmod +x /opt/watchlog.sh
   ```
   >*root@nubuntu2404:/opt# chmod +x /opt/watchlog.sh*
6. Создаём Unit для сервиса.
   ```
   cat << EOF >> /etc/systemd/system/watchlog.service
   [Unit]
   Description=My watchlog service
   [Service]
   Type=oneshot
   EnvironmentFile=/etc/default/watchlog
   ExecStart=/opt/watchlog.sh $WORD $LOG
   EOF
   ```
   >*root@nubuntu2404:/# cat << EOF >> /etc/systemd/system/watchlog.service   
   [Unit]   
   Description=My watchlog service   
   [Service]   
   Type=oneshot   
   EnvironmentFile=/etc/default/watchlog   
   ExecStart=/opt/watchlog.sh $WORD $LOG    
   EOF*   

7. Создаём Unit для таймера.
   ```
   cat <<EOF >> /etc/systemd/system/watchlog.timer   
   [Unit]    
   Description=Run watchlog script every 30 second    
   [Timer]   
   # Run every 30 second    
   OnUnitActiveSec=30    
   Unit=watchlog.service   
   [Install]    
   WantedBy=multi-user.target    
   EOF   
   ```
   >*root@nubuntu2404:/# cat <<EOF >> /etc/systemd/system/watchlog.timer   
   [Unit]    
   Description=Run watchlog script every 30 second    
   [Timer]   
   #Run every 30 second    
   OnUnitActiveSec=30    
   Unit=watchlog.service   
   [Install]    
   WantedBy=multi-user.target    
   EOF   
   root@nubuntu2404:/#*    
8. Запускаем созданные Unit для таймера и сервиса.
   ```
   systemctl start watchlog.timer
   ```
   >*root@nubuntu2404:/# systemctl start watchlog.timer*
   ```
   systemctl start watchlog.service
   ```
   >*root@nubuntu2404:/# systemctl start watchlog.service*

9. Проверяем работу.
   ```
   tail -n 1000 /var/log/syslog | grep word 
   ```
   >*root@nubuntu2404:/# tail -n 1000 /var/log/syslog | grep word    
2025-05-11T18:51:02.676130+00:00 nubuntu2404 systemd[1]: Started systemd-ask-password-console.path - Dispatch Password Requests to Console Directory Watch.    
2025-05-11T18:51:02.676138+00:00 nubuntu2404 systemd[1]: systemd-ask-password-plymouth.path - Forward Password Requests to Plymouth Directory Watch was skipped because of an unmet condition check (ConditionPathExists=/run/plymouth/pid).    
2025-05-11T18:51:02.742616+00:00 nubuntu2404 kernel: systemd[1]: Started systemd-ask-password-wall.path - Forward Password Requests to Wall Directory Watch.    
2025-05-11T18:51:02.742792+00:00 nubuntu2404 kernel: audit: type=1400 audit(1746989455.982:2): apparmor="STATUS" operation="profile_load" profile="unconfined" name="1password" pid=469 comm="apparmor_parser"    
2025-05-11T21:11:48.577979+00:00 nubuntu2404 root: Sun May 11 09:11:48 PM UTC 2025: I found word, Master!   
2025-05-11T21:11:51.135921+00:00 nubuntu2404 root: Sun May 11 09:11:51 PM UTC 2025: I found word, Master!    
2025-05-11T21:12:34.740804+00:00 nubuntu2404 root: Sun May 11 09:12:34 PM UTC 2025: I found word, Master!   
2025-05-11T21:13:24.749906+00:00 nubuntu2404 root: Sun May 11 09:13:24 PM UTC 2025: I found word, Master!   
2025-05-11T21:14:34.725747+00:00 nubuntu2404 root: Sun May 11 09:14:34 PM UTC 2025: I found word, Master!   
2025-05-11T21:15:44.721460+00:00 nubuntu2404 root: Sun May 11 09:15:44 PM UTC 2025: I found word, Master!    
2025-05-11T21:16:44.759779+00:00 nubuntu2404 root: Sun May 11 09:16:44 PM UTC 2025: I found word, Master!   
2025-05-11T21:18:34.741291+00:00 nubuntu2404 root: Sun May 11 09:18:34 PM UTC 2025: I found word, Master!   
2025-05-11T21:20:24.751357+00:00 nubuntu2404 root: Sun May 11 09:20:24 PM UTC 2025: I found word, Master!   
2025-05-11T21:21:34.719551+00:00 nubuntu2404 root: Sun May 11 09:21:34 PM UTC 2025: I found word, Master!   
2025-05-11T21:22:44.758722+00:00 nubuntu2404 root: Sun May 11 09:22:44 PM UTC 2025: I found word, Master!   
2025-05-11T21:34:24.719512+00:00 nubuntu2404 root: Sun May 11 09:34:24 PM UTC 2025: I found word, Master!*   
  
### Переделываем **unit**-файл с помощью переделки **init**-скрипта.   
  
10. Устанавливаем обработчик **spawn-fcgi** и все необходимые для него компоненты.    
    ```
    apt install spawn-fcgi php php-cgi php-cli apache2 libapache2-mod-fcgid -y
    ```
    >*root@nubuntu2404:/# apt install spawn-fcgi php php-cgi php-cli apache2 libapache2-mod-fcgid -y   
   Reading package lists... Done   
   Building dependency tree... Done   
   Reading state information... Done   
   spawn-fcgi is already the newest version (1.6.4-2).   
   The following additional packages will be installed:   
   apache2-bin apache2-data apache2-utils libapache2-mod-php8.3 libapr1t64 libaprutil1-dbd-sqlite3 libaprutil1-ldap libaprutil1t64 liblua5.4-0   
   php-common php8.3 php8.3-cgi php8.3-cli php8.3-common php8.3-opcache php8.3-readline ssl-cert   
   Suggested packages:   
   apache2-doc apache2-suexec-pristine | apache2-suexec-custom www-browser php-pear   
   The following NEW packages will be installed:   
   apache2 apache2-bin apache2-data apache2-utils libapache2-mod-fcgid libapache2-mod-php8.3 libapr1t64 libaprutil1-dbd-sqlite3   
   libaprutil1-ldap libaprutil1t64 liblua5.4-0 php php-cgi php-cli php-common php8.3 php8.3-cgi php8.3-cli php8.3-common php8.3-opcache   
   php8.3-readline ssl-cert   
   0 upgraded, 22 newly installed, 0 to remove and 64 not upgraded.   
   Need to get 8,942 kB of archives.   
   After this operation, 42.1 MB of additional disk space will be used.*    

   
11. Создаём конфигурационный файл **fcgi.conf** в каталоге */etc/spawn-fcgi* содержащий следующий текст:      

    ***\# You must set some working options before the "spawn-fcgi" service will work.   
     \# If SOCKET points to a file, then this file is cleaned up by the init script.   
     \# See spawn-fcgi(1) for all possible options.   
     \# Example :   
     SOCKET=/var/run/php-fcgi.sock   
     OPTIONS="-u www-data -g www-data -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"***    
 
    ```
    mkdir /etc/spawn-fcgi && cd /etc/spawn-fcgi && touch fcgi.conf    
    ```
    >*root@nubuntu2404:/# mkdir /etc/spawn-fcgi && cd /etc/spawn-fcgi && touch fcgi.conf
    root@nubuntu2404:/etc/spawn-fcgi# nano fcgi.conf*
    <pre>
      GNU nano 7.2                                      fcgi.conf   
    # You must set some working options before the "spawn-fcgi" service will work.   
    # If SOCKET points to a file, then this file is cleaned up by the init script.   
    # See spawn-fcgi(1) for all possible options.   
    # Example :   
    SOCKET=/var/run/php-fcgi.sock   
    OPTIONS="-u www-data -g www-data -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"   
    </pre>

12. Создаём unit-файл **spawn-fcgi.service**
    ```
    cat << EOF >> /etc/systemd/system/spawn-fcgi.service
      [Unit]
      Description=Spawn-fcgi startup service by Otus
      After=network.target
      [Service]
      Type=simple
      PIDFile=/var/run/spawn-fcgi.pid
      EnvironmentFile=/etc/spawn-fcgi/fcgi.conf
      ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
      KillMode=process
      [Install]
      WantedBy=multi-user.target
      EOF
    ```
    >*root@nubuntu2404:/# cat << EOF >> /etc/systemd/system/spawn-fcgi.service   
      [Unit]   
      Description=Spawn-fcgi startup service by Otus   
      After=network.target   
      [Service]   
      Type=simple   
      PIDFile=/var/run/spawn-fcgi.pid   
      EnvironmentFile=/etc/spawn-fcgi/fcgi.conf    
      ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS   
      KillMode=process   
      [Install]    
      WantedBy=multi-user.target   
      EOF*    

13. Запускаем сервис **spawn-fcgi.service**
    ```
    systemctl start spawn-fcgi
    ```
    >*root@nubuntu2404:/# systemctl start spawn-fcgi*

    ```
    systemctl status spawn-fcgi
    ```
    >*root@nubuntu2404:/# systemctl status spawn-fcgi   
● spawn-fcgi.service - Spawn-fcgi startup service by Otus   
     Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; preset: enabled)   
     Active: active (running) since Mon 2025-05-12 22:54:39 UTC; 1s ago   
   Main PID: 24969 (php-cgi)   
      Tasks: 33 (limit: 2272)   
     Memory: 14.7M (peak: 14.9M)   
        CPU: 69ms   
     CGroup: /system.slice/spawn-fcgi.service   
             ├─24969 /usr/bin/php-cgi   
             ├─24970 /usr/bin/php-cgi   
             ├─24971 /usr/bin/php-cgi   
             ├─24972 /usr/bin/php-cgi   
             ├─24973 /usr/bin/php-cgi   
             ├─24974 /usr/bin/php-cgi   
             ├─24975 /usr/bin/php-cgi   
             ├─24976 /usr/bin/php-cgi   
             ├─24977 /usr/bin/php-cgi   
             ├─24978 /usr/bin/php-cgi   
             ├─24979 /usr/bin/php-cgi   
             ├─24980 /usr/bin/php-cgi   
             ├─24981 /usr/bin/php-cgi   
             ├─24982 /usr/bin/php-cgi   
             ├─24983 /usr/bin/php-cgi   
             ├─24984 /usr/bin/php-cgi    
             ├─24985 /usr/bin/php-cgi    
             ├─24986 /usr/bin/php-cgi   
             ├─24987 /usr/bin/php-cgi    
             ├─24988 /usr/bin/php-cgi   
             ├─24989 /usr/bin/php-cgi   
             ├─24990 /usr/bin/php-cgi   
             ├─24991 /usr/bin/php-cgi   
             ├─24992 /usr/bin/php-cgi   
             ├─24993 /usr/bin/php-cgi   
             ├─24994 /usr/bin/php-cgi   
             ├─24995 /usr/bin/php-cgi   
             ├─24996 /usr/bin/php-cgi   
             ├─24997 /usr/bin/php-cgi   
             ├─24998 /usr/bin/php-cgi   
             ├─24999 /usr/bin/php-cgi   
             ├─25000 /usr/bin/php-cgi   
             └─25001 /usr/bin/php-cgi   
May 12 22:54:39 nubuntu2404 systemd[1]: Started spawn-fcgi.service - Spawn-fcgi startup service by Otus.*
      
 ### Доработать **unit**-файл Nginx (**nginx.service**) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно.
14. Устанавливаем **Nginx** из репозитория.
    ```
    apt install nginx -y
    ```
    >*root@nubuntu2404:/# apt install nginx -y   
Reading package lists... Done   
Building dependency tree... Done   
Reading state information... Done   
The following additional packages will be installed:   
  nginx-common   
Suggested packages:   
  fcgiwrap nginx-doc   
The following NEW packages will be installed:   
  nginx nginx-common   
0 upgraded, 2 newly installed, 0 to remove and 64 not upgraded.   
Need to get 551 kB of archives.   
After this operation, 1,596 kB of additional disk space will be used.    
Get:1 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 nginx-common all 1.24.0-2ubuntu7.3 [31.2 kB]    
Get:2 http://ru.archive.ubuntu.com/ubuntu noble-updates/main amd64 nginx amd64 1.24.0-2ubuntu7.3 [520 kB]     
Fetched 551 kB in 0s (3,915 kB/s)     
Preconfiguring packages ...*
    
15. Создаём новый Unit-файл для работы с шаблонами **nginx@.service** в каталоге */etc/systemd/system*
    ```
    cat << EOF >> /etc/systemd/system/nginx@.service
      # Stop dance for nginx
      # =======================
      # ExecStop sends SIGSTOP (graceful stop) to the nginx process.
      # If, after 5s (--retry QUIT/5) nginx is still running, systemd takes control
      # and sends SIGTERM (fast shutdown) to the main process.
      # After another 5s (TimeoutStopSec=5), and if nginx is alive, systemd sends
      # SIGKILL to all the remaining processes in the process group (KillMode=mixed).
      # nginx signals reference doc:
      # http://nginx.org/en/docs/control.html
      #
      [Unit]
      Description=A high performance web server and a reverse proxy server
      Documentation=man:nginx(8)
      After=network.target nss-lookup.target
      [Service]
      Type=forking
      PIDFile=/run/nginx-%I.pid
      ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%I.conf -q -g 'daemon on; master_process on;'
      ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;'
      ExecReload=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;' -s reload
      ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx-%I.pid
      TimeoutStopSec=5
      KillMode=mixed
      [Install]
      WantedBy=multi-user.target
      EOF*
    ```
    >*root@nubuntu2404:/# cat << EOF >> /etc/systemd/system/nginx@.service
      \# Stop dance for nginx
      \# =======================
      \# ExecStop sends SIGSTOP (graceful stop) to the nginx process.
      \# If, after 5s (--retry QUIT/5) nginx is still running, systemd takes control
      \# and sends SIGTERM (fast shutdown) to the main process.
      \# After another 5s (TimeoutStopSec=5), and if nginx is alive, systemd sends
      \# SIGKILL to all the remaining processes in the process group (KillMode=mixed).
      \# nginx signals reference doc:
      \# http://nginx.org/en/docs/control.html
      \#
      [Unit]
      Description=A high performance web server and a reverse proxy server
      Documentation=man:nginx(8)
      After=network.target nss-lookup.target
      [Service]
      Type=forking
      PIDFile=/run/nginx-%I.pid
      ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%I.conf -q -g 'daemon on; master_process on;'
      ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;'
      ExecReload=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;' -s reload
      ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx-%I.pid
      TimeoutStopSec=5
      KillMode=mixed
      [Install]
      WantedBy=multi-user.target
      EOF*

16. Создаём 2 конфигурационных файла **(/etc/nginx/nginx-first.conf, /etc/nginx/nginx-second.conf)**, на основе стандартного конфига **nginx.conf** c разделением по портам и модификацией путей до pid - файлов.     
    
    ```
    cp nginx.conf nginx-first.conf   
    ```
    >*root@nubuntu2404:/etc/nginx# cp nginx.conf nginx-first.conf*     
    
    ```
    cp nginx.conf nginx-second.conf    
    ```
    >*root@nubuntu2404:/etc/nginx# cp nginx.conf nginx-second.conf*    


18. ддн

    

