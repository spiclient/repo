<h1 align="center">ДЗ №1.Обновление ядра системы Linux</h1>

## Цель домашнего задания:
+ Научиться обновлять ядро в ОС Linux.
## Программные средства
+ VirtualBox 7.1.6
+ Visual Studio Code 1.97.2
+ PuTTY 0.73
## Описание домашнего задания:
   + Запустить ВМ c Ubuntu.
   + Вариант 1. Обновить ядро ОС на новейшую стабильную версию из mainline-репозитория.
   + Вариант 2. Собрать ядро из исходных кодов.
   + Оформить отчет в README-файле в GitHub-репозитории.
## Выполнение
1. Скачиваем iso-образ [Ubuntu 22.04.5](https://www.releases.ubuntu.com/22.04/) с официального сайта.
2. В VirtualBox создаём виртуальную машину из скачанного образа и запускаем её.
3. Выполняем предварительную настройку системы: 
    + устанавливаем пароль на root
      ```
      sudo passwd
      ```
      >*user@nUbuntu2204:~$ sudo passwd  
      [sudo] password for user:  
      New password:  
      Retype new password:  
      passwd: password updated successfully*

    + устанавливаем ssh-server
      ```
      sudo apt install openssh-server
      ```
      >*user@nUbuntu2204:~$ sudo apt install openssh-server  
Reading package lists... Done  
Building dependency tree... Done  
Reading state information... Done  
Suggested packages:*.............

    + проверяем статус ssh
      ```
      systemctl status ssh
      ```
      >*user@nUbuntu2204:~$ systemctl status ssh  
● ssh.service - OpenBSD Secure Shell server  
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: en>  
     Active: active (running) since Thu 2025-03-06 16:22:24 UTC; 18min ago  
       Docs: man:sshd(8)  
             man:sshd_config(5)  
   Main PID: 1846 (sshd)  
      Tasks: 1 (limit: 2224)  
     Memory: 4.0M  
        CPU: 211ms  
     CGroup: /system.slice/ssh.service  
             └─1846 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"*

    + подключаемся к терминалу ВМ используя программу PuTTy
    
    
      
4. **Вариант 1.** Обновление ядра из mainline-репозитория
   + проверяем версию ядра 
      ```
      uname -r
      ```
      >*user@nUbuntu2204:~$ uname -r  
5.15.0-134-generic*

    + проверяем архитектуру ядра
      ```
      uname -p
      ```
      >*user@nUbuntu2204:~$ uname -p  
x86_64*

    + находим свежую версию ядра для нашей архитектуры в репозитории [Ubuntu Mainline PPA](https://kernel.ubuntu.com/mainline)
    + сохраняем ссылки на .deb-пакеты
    + в терминале создаем каталог **kernel** и сразу переходим в него
      ```
      mkdir kernel && cd kernel
      ```

    + загружаем последовательно в каталог **kernel** .deb-пакеты с помощью команды *wget* и используя сохраненные ссылки
      ```
      wget https://kernel.ubuntu.com/mainline/v6.14-rc5/amd64/linux-headers-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb
      ```
      ```
      wget https://kernel.ubuntu.com/mainline/v6.14-rc5/amd64/linux-headers-6.14.0-061400rc5_6.14.0-061400rc5.202503022109_all.deb
      ```
      ```
      wget https://kernel.ubuntu.com/mainline/v6.14-rc5/amd64/linux-image-unsigned-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb
      ```
      ```
      wget https://kernel.ubuntu.com/mainline/v6.14-rc5/amd64/linux-modules-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb    
      ```
    + устанавливаем все пакеты сразу
      ```
      sudo dpkg -i *.deb
      ```
    + проверяем, что ядро появилось в */boot*.
      ```
      ls -al /boot
      ```
    + обновляем конфигурацию загрузчика 
      ```
      sudo update-grub
      ```
    +  устанавливаем загрузку нового ядра по-умолчанию
       ```
       sudo grub-set-default 0
       ```
    + перезагружаем систему
      ```
      reboot
      ```
    + проверяем версию ядра 
      ```
      uname -r
      ```
     
1. **Вариант 2.** Собрать ядро из исходных кодов
  
    + проверяем версию ядра 
      ```
      uname -r
      ```
      >*user@nUbuntu2204:~$ uname -r  
5.15.0-134-generic*

    + проверяем архитектуру ядра
      ```
      uname -p
      ```
      >*user@nUbuntu2204:~$ uname -p  
x86_64*
    + открываем сайт [Kernel.org](https://kernel.org/) копируем ссылку на архив исходников ядра
      
    + в терминале переходим в каталог **root**
      ```
      cd /root
      ```
    + загружаем архив исходников ядра с помощью команды *wget* и используя сохраненную ссылку
      ```
      wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.13.5.tar.xz
      ```
    + разархивируем скачанный архив 
       ```
       tar -Jxvf linux-6.13.5.tar.xz
       ```
    + переходим в каталог в который распаковался архив
      ```
      cd linux-6.13.5
      ```
     
    + устанавливаем инструменты для сборки
      ```
      apt install build-essential libncurses-dev bison flex libssl-dev libelf-dev
      ```
    + создаем файл конфигурации
      ```
      make nconfig
      ```
    + открываем редактором файл конфигурации, находим строки *debian/canonical-certs.pem* и удаляем их
      ```
      nano .config
      ```
    + запускаем сборку ядра
      ```
      make 
      ```
    + перезагружаем систему
      ```
      reboot
      ```
    + проверяем версию ядра 
      ```
      uname -r
      ```
