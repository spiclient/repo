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
   <pre/>



5. kgjkgk
