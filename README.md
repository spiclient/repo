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
   Включаем вложенную виртуализацию, если VirtualBox установлен под Linux.   
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

2. Cоздаём файл с конфигурацией для сервиса в директории */etc/default*.
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



   ### Переделываем **unit**-файл с помощью переделки **init**-скрипта.
   
4. Устанавливаем обработчик **spawn-fcgi**
   ```
   apt -y install spawn-fcgi
   ```
   >*root@nubuntu2404:~# apt -y install spawn-fcgi   
Reading package lists... Done   
Building dependency tree... Done   
Reading state information... Done   
The following NEW packages will be installed:   
  spawn-fcgi   
0 upgraded, 1 newly installed, 0 to remove and 64 not upgraded.   
Need to get 14.9 kB of archives.   
After this operation, 48.1 kB of additional disk space will be used.   
Get:1 http://ru.archive.ubuntu.com/ubuntu noble/universe amd64 spawn-fcgi amd64 1.6.4-2 [14.9 kB]    
Fetched 14.9 kB in 0s (77.9 kB/s)    
Selecting previously unselected package spawn-fcgi.    
(Reading database ... 86743 files and directories currently installed.)    
Preparing to unpack .../spawn-fcgi_1.6.4-2_amd64.deb ...    
Unpacking spawn-fcgi (1.6.4-2) ...    
Setting up spawn-fcgi (1.6.4-2) ...    
Processing triggers for man-db (2.12.0-4build2) ...    
Scanning processes...     
Scanning linux images...    
Running kernel seems to be up-to-date.     
No services need to be restarted.     
No containers need to be restarted.    
No user sessions are running outdated binaries.    
No VM guests are running outdated hypervisor (qemu) binaries on this host.*    

   


5. ожож

