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
   Включаем вложенную виртуализацию.   
   **a.** запускаем PowerShell от имени администратора       
   **с.** выводим список ВМ      
      ```
      VBoxManage list vms
      ```
      >*PS C:\WINDOWS\system32> VBoxManage list vms   
"nUbunta2404" {9a4944e1-f09c-466e-973d-bbc303b9fc7a}*   
      
   **d.** включаем вложенную виртуализацию(ВМ должна быть выключена)    
      ```
      VBoxManage.exe modifyvm "nUbunta2404" --nested-hw-virt on
      ```
      >*PS C:\WINDOWS\system32> VBoxManage.exe modifyvm "nUbunta2404" --nested-hw-virt on*
   #### Вк///////.   
3. Открываем     

