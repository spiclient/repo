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

   


7. ожож

