<h1 align="center">ДЗ №6.Сборка RPM-пакета и создание репозитория.</h1>

## Цель домашнего задания:
+ Научиться собирать RPM-пакеты.
+ Научиться создавать собственный RPM-репозиторий.
## Программные средства
+ VirtualBox 7.1.6
+ MobaXterm
## Описание домашнего задания:
   + Создать свой RPM пакет(можно взять свое приложение, либо собрать, например, Apache с определенными опциями).
   + Создать свой репозиторий и разместить там ранее собранный RPM.

## Выполнение
### Основная часть. 
1. Создаём виртуальную машину(ВМ) под управлением ОС AlmaLinux 9.5.
2. Устанавливаем и запускаем сервис **SSH** для подключения через удаленный терминал.      
   **a.** устанавливаем пакет **openssh-server**    
   ```
   sudo dnf install openssh-server
   ```
   **b.** запускаем сервис   
   ```
   sudo systemctl start sshd
   ```
   **c.** включаем автоматический запуск сервиса SSH при загрузке системы   
   ```
   sudo systemctl enable sshd
   ```
3. Включаем на виртуальной машине **Almalinux** вложенную виртуализацию Nested Virtualization в VirtualBox.    

   ***Первый способ:***    
   **a.** открываем VirtualBox и находим целевую ВМ    
   **b.** ПКМ - Настроить - Система - Процессор - (включаем чекбокс)Включить Nested VT-x/AMD   
   если параметр неактивен переходим ко ***Второму способу***:    
   **a.** добавляем путь *C:\Program Files\Oracle\VirtualBox* в системные переменные среды(Windows)    
   **b.** запускаем PowerShell от имени администратора    
   **с.** выводим список ВМ    
      ```
      VBoxManage list vms
      ```
      >*PS C:\WINDOWS\system32> VBoxManage list vms
      "Almalinux" {8f118b90-d0ef-46b6-949a-91a663846a2b}*   
      
   **d.** включаем вложенную виртуализацию(ВМ должна быть выключена)    
      ```
      VBoxManage.exe modifyvm "Almalinux" --nested-hw-virt on
      ```
      >*PS C:\WINDOWS\system32> VBoxManage.exe modifyvm "Almalinux" --nested-hw-virt on*

4. Устанавливаем набор инструментов для работы с RPM    
   ```
   sudo yum install -y wget rpmdevtools rpm-build createrepo yum-utils cmake gcc git nano    
   ```
   >*[user@Almalinux ~]$ sudo yum install -y wget rpmdevtools rpm-build createrepo yum-utils cmake gcc git nano      
[sudo] password for user:      
Last metadata expiration check: 1:41:24 ago on Sat May  3 22:36:07 2025.      
Dependencies resolved.*     
   <pre>
   =================================================================================================================================
   Package                              Architecture         Version                                 Repository               Size
   =================================================================================================================================
   Installing:
    cmake                                x86_64               3.26.5-2.el9                            appstream               8.7 M
    createrepo_c                         x86_64               0.20.1-2.el9                            appstream                73 k
    gcc                                  x86_64               11.5.0-5.el9_5.alma.1                   appstream                32 M
    git                                  x86_64               2.43.5-2.el9_5                          appstream                50 k
    nano                                 x86_64               5.6.1-6.el9                             baseos                  691 k
    rpm-build                            x86_64               4.16.1.3-34.el9                         appstream                59 k
    rpmdevtools                          noarch               9.5-1.el9                               appstream                75 k
    wget                                 x86_64               1.21.1-8.el9_4                          appstream               768 k
    yum-utils                            noarch               4.3.0-16.el9                            baseos                   35 k
   Installing dependencies:
    annobin                              x86_64               12.65-1.el9                             appstream               1.0 M
    bzip2                                x86_64               1.0.8-10.el9_5                          baseos                   51 k
    cmake-data                           noarch               3.26.5-2.el9                            appstream               1.7 M
    cmake-filesystem                     x86_64               3.26.5-2.el9                            appstream                11 k
    cmake-rpm-macros                     noarch               3.26.5-2.el9                            appstream                10 k
    cpp                                  x86_64               11.5.0-5.el9_5.alma.1                   appstream                11 M
    createrepo_c-libs                    x86_64               0.20.1-2.el9                            appstream                99 k
    debugedit                            x86_64               5.0-5.el9                               appstream                75 k
    dwz                                  x86_64               0.14-3.el9                              appstream               127 k
    ed                                   x86_64               1.14.2-12.el9                           baseos                   74 k
    efi-srpm-macros                      noarch               6-2.el9_0.0.1                           appstream                21 k
    elfutils                             x86_64               0.191-4.el9.alma.1                      baseos                  549 k
    emacs-filesystem                     noarch               1:27.2-11.el9_5.1                       appstream               7.8 k
    fonts-srpm-macros                    noarch               1:2.0.5-7.el9.1                         appstream                27 k
    gcc-plugin-annobin                   x86_64               11.5.0-5.el9_5.alma.1                   appstream                39 k
    gdb-minimal                          x86_64               14.2-3.el9                              appstream               4.2 M
    ---и т.д---
   <pre/>



5. Будем работать с пакетом **Nginx** для разворачивания веб-сервера и дополнительно установим модуль для сжатия данных **ngx_broli**.
6. Создаём директорию **RPM** и скачиваем в неё исходники пакета **Nginx**
   ```
   mkdir rpm && cd rpm
   ```
   >*[user@Almalinux ~]$ mkdir rpm && cd rpm*

   ```
   yumdownloader --source nginx
   ```
   >*[user@Almalinux rpm]$ yumdownloader --source nginx   
enabling appstream-source repository   
enabling baseos-source repository   
enabling extras-source repository   
AlmaLinux 9 - AppStream                                                                          3.5 MB/s |  16 MB     00:04   
AlmaLinux 9 - AppStream - Source                                                                 275 kB/s | 866 kB     00:03   
AlmaLinux 9 - BaseOS                                                                             2.9 MB/s |  19 MB     00:06   
AlmaLinux 9 - BaseOS - Source                                                                    130 kB/s | 315 kB     00:02   
AlmaLinux 9 - Extras                                                                              22 kB/s |  13 kB     00:00   
AlmaLinux 9 - Extras - Source                                                                    6.5 kB/s | 8.2 kB     00:01   
nginx-1.20.1-20.el9.alma.1.src.rpm                                                               432 kB/s | 1.1 MB     00:02*   

7. Устанавливаем скачанный пакет.
   ```
   sudo rpm -Uvh nginx*.src.rpm 
   ```
   >_[user@Almalinux rpm]$ rpm -Uvh nginx*.src.rpm   
     Updating / installing...
     1:nginx-2:1.20.1-20.el9.alma.1     warning: user mockbuild does not exist - using root_   
8. Устанавливаем зависимости, необходимые для сборки пакета **Nginx**
   ```
   yum-builddep nginx
   ```
   >*[root@Almalinux rpm]# yum-builddep nginx   
enabling appstream-source repository   
enabling baseos-source repository   
enabling extras-source repository   
Last metadata expiration check: 0:00:44 ago on Sun May  4 01:17:39 2025.   
Package make-1:4.3-8.el9.x86_64 is already installed.   
Package gcc-11.5.0-5.el9_5.alma.1.x86_64 is already installed.   
Package systemd-252-46.el9_5.3.alma.1.x86_64 is already installed.   
Package gnupg2-2.3.3-4.el9.x86_64 is already installed.   
Dependencies resolved.*
  <pre>
     =================================================================================================================================
     Package                                   Architecture         Version                            Repository               Size
     =================================================================================================================================
      Installing:
       gd-devel                                  x86_64               2.3.2-3.el9                        appstream                37 k
       libxslt-devel                             x86_64               1.1.34-9.el9_5.3                   appstream               287 k
       openssl-devel                             x86_64               1:3.2.2-6.el9_5.1                  appstream               3.2 M
       pcre-devel                                x86_64               8.44-4.el9                         appstream               469 k
       perl-ExtUtils-Embed                       noarch               1.35-481.el9                       appstream                16 k
       perl-devel                                x86_64               4:5.32.1-481.el9                   appstream               659 k
       perl-generators                           noarch               1.11-12.el9                        appstream                15 k
       zlib-devel                                x86_64               1.2.11-40.el9                      appstream                44 k
      Installing dependencies:
       brotli                                    x86_64               1.0.9-7.el9_5                      appstream               311 k
       brotli-devel                              x86_64               1.0.9-7.el9_5                      appstream                30 k
       bzip2-devel                               x86_64               1.0.8-10.el9_5                     appstream               213 k
       cairo                                     x86_64               1.17.4-7.el9                       appstream               659 k
       dejavu-sans-fonts                         noarch               2.37-18.el9                        baseos                  1.3 M
       fontconfig                                x86_64               2.14.0-2.el9_1                     appstream               274 k
       fontconfig-devel                          x86_64               2.14.0-2.el9_1                     appstream               127 k
       fonts-filesystem                          noarch               1:2.0.5-7.el9.1                    baseos                  9.0 k
       freetype-devel                            x86_64               2.10.4-10.el9_5                    appstream               1.1 M
       gd                                        x86_64               2.3.2-3.el9                        appstream               131 k
       glib2-devel                               x86_64               2.68.4-14.el9_4.1                  appstream               471 k
       graphite2-devel                           x86_64               1.3.14-9.el9                       appstream                21 k
       harfbuzz-devel                            x86_64               2.7.4-10.el9                       appstream               304 k
       harfbuzz-icu                              x86_64               2.7.4-10.el9                       appstream                13 k
       jbigkit-libs                              x86_64               2.1-23.el9                         appstream                52 k
       langpacks-core-font-en                    noarch               3.0-16.el9                         appstream               9.4 k
       libICE                                    x86_64               1.0.10-8.el9                       appstream                70 k
       libSM                                     x86_64               1.2.3-10.el9                       appstream                41 k
       libX11                                    x86_64               1.7.0-9.el9                        appstream               645 k
  </pre>
    

   
   
10. опрпропропро
