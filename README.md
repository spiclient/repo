<h1 align="center">ДЗ №1.Обновление ядра системы Linux</h1>

## Цель домашнего задания:
+ Научиться обновлять ядро в ОС Linux.
## Программные средства
+ VirtualBox 7.1.6
+ Visual Studio Code 1.97.2
+ MobaXterm
## Описание домашнего задания:
   + Запустить ВМ c Ubuntu или Debian.
   + Вариант 1. Обновить ядро ОС на новейшую стабильную версию из mainline-репозитория.
   + Вариант 2. Собрать ядро из исходных кодов.
   + Оформить отчет в *README*-файле в **GitHub**-репозитории.
## Выполнение
1. Скачиваем *iso*-образы [Ubuntu 22.04.5](https://www.releases.ubuntu.com/22.04/) и [Debian 11.0.0](https://cdimage.debian.org/cdimage/archive/11.0.0/i386/iso-dvd/debian-11.0.0-i386-DVD-1.iso) с официального сайта.
2. В **VirtualBox** создаём виртуальные машины из скачанных образов. При разворачивании ВМ из Debian-образа устанавливаем дополнительно компонент **ssh-server**.
3. Выполняем предварительную настройку системы **Ubuntu**: 
    + устанавливаем пароль на суперпользователя **root**
      ```
      sudo passwd
      ```
      >*user@nUbuntu2204:~$ sudo passwd  
      [sudo] password for user:  
      New password:  
      Retype new password:  
      passwd: password updated successfully*

    + устанавливаем **ssh-server**
      ```
      sudo apt install openssh-server
      ```
      >*user@nUbuntu2204:~$ sudo apt install openssh-server  
Reading package lists... Done  
Building dependency tree... Done  
Reading state information... Done  
Suggested packages:  
....................*

    + проверяем статус **ssh**
      ```
      systemctl status ssh
      ```
      >*user@nUbuntu2204:~$ systemctl status ssh  
● ssh.service - OpenBSD Secure Shell server  
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)  
     Active: active (running) since Thu 2025-03-06 16:22:24 UTC; 18min ago  
       Docs: man:sshd(8)  
             man:sshd_config(5)  
   Main PID: 1846 (sshd)  
      Tasks: 1 (limit: 2224)  
     Memory: 4.0M  
        CPU: 211ms  
     CGroup: /system.slice/ssh.service  
             └─1846 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"*
     
4. Выполняем предварительную настройку системы **Debian**: 
    + устанавливаем пароль на суперпользователя **root**
      ```
      passwd root
      ```
      >*root@vbox:/home/user# passwd root  
      New password:  
      Retype new password:  
      passwd: password updated successfully*

    + проверяем статус **ssh**
      ```
      systemctl status ssh
      ```
      >*root@vbox:/home/user# systemctl status ssh  
● ssh.service - OpenBSD Secure Shell server  
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)  
     Active: active (running) since Sat 2025-03-22 11:09:32 MSK; 28min ago  
       Docs: man:sshd(8)  
             man:sshd_config(5)
   Process: 381 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 391 (sshd)  
      Tasks: 1 (limit: 4915)  
     Memory: 5.9M  
        CPU: 915ms  
     CGroup: /system.slice/ssh.service  
             └─391 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"*

5. Подключаемся к терминалам ВМ используя программу **MobaXterm**
6. **Вариант 1.** Обновление ядра из mainline-репозитория. **Ubuntu 22.04.5**
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
    + сохраняем ссылки на *.deb*-пакеты
    + в терминале создаем каталог **kernel** и сразу переходим в него
      ```
      mkdir kernel && cd kernel
      ```
      >*user@nUbuntu2204:~ $mkdir kernel *&&* cd kernel  
      user@nUbuntu2204:~/kernel$*


    + в каталог **kernel** загружаем последовательно *.deb*-пакеты с помощью команды ***wget*** и используя сохраненные ссылки
      ```
      wget https://kernel.ubuntu.com/mainline/v6.14-rc5/amd64/linux-headers-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb
      ```
      >*user@nUbuntu2204:~/kernel$ wget https://kernel.ubuntu.com/mainline/v6.14-rc5/amd  
      64/linux-headers-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb  
      --2025-03-07 04:27:35--  https://kernel.ubuntu.com/mainline/v6.14-rc5/amd64/linu  
      x-headers-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb  
      Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 185.125.189.75, 185.125.189.76, 185.125.189.74  
      Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|185.125.189.75|:443... connected.  
      HTTP request sent, awaiting response... 200 OK  
      Length: 3718514 (3.5M) [application/x-debian-package]  
      Saving to: ‘linux-headers-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb’  
      linux-headers-6.14. 100%[===================>]   3.55M  6.22MB/s    in 0.6s  
      2025-03-07 04:27:36 (6.22 MB/s) - ‘linux-headers-6.14.0-061400rc5-generic_6.14.0  
      -061400rc5.202503022109_amd64.deb’ saved [3718514/3718514]*

      ```
      wget https://kernel.ubuntu.com/mainline/v6.14-rc5/amd64/linux-headers-6.14.0-061400rc5_6.14.0-061400rc5.202503022109_all.deb
      ```
      >*user@nUbuntu2204:~/kernel$ wget https://kernel.ubuntu.com/mainline/v6.14-rc5/amd  
      64/linux-headers-6.14.0-061400rc5_6.14.0-061400rc5.202503022109_all.deb  
      --2025-03-07 04:39:23--  https://kernel.ubuntu.com/mainline/v6.14-rc5/amd64/linux-  
      headers-6.14.0-061400rc5_6.14.0-061400rc5.202503022109_all.deb  
      Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 185.125.189.74, 185.125.189.76, 185.125.189.75  
      Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|185.125.189.74|:443... connected.  
      HTTP request sent, awaiting response... 200 OK  
      Length: 13960172 (13M) [application/x-debian-package]  
      Saving to: ‘linux-headers-6.14.0-061400rc5_6.14.0-061400rc5.202503022109_all.deb’  
      linux-headers-6.14.0-06140 100%[======================================>]  13.31M  9.00MB/s    in 1.5s  
      2025-03-07 04:39:25 (9.00 MB/s) - ‘linux-headers-6.14.0-061400rc5_6.14.0-061400rc5.202503022109_all.deb’ saved [13960172/13960172]*

      ```
      wget https://kernel.ubuntu.com/mainline/v6.14-rc5/amd64/linux-image-unsigned-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb
      ```
      >*user@nUbuntu2204:~/kernel$ wget https://kernel.ubuntu.com/mainline/v6.14-rc5/amd  
      64/linux-image-unsigned-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb  
      --2025-03-07 04:40:36--  https://kernel.ubuntu.com/mainline/v6.14-rc5/amd64/linux-image-unsigned-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb  
      Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 185.125.189.75, 185.125.189.74, 185.125.189.76  
      Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|185.125.189.75|:443... connected.  
      HTTP request sent, awaiting response... 200 OK  
      Length: 15718592 (15M) [application/x-debian-package]  
      Saving to: ‘linux-image-unsigned-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb’  
      linux-image-unsigned-6.14. 100%[======================================>]  14.99M  8.31MB/s    in 1.8s  
      2025-03-07 04:40:38 (8.31 MB/s) - ‘linux-image-unsigned-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb’ saved [15718592/15718592]*

      ```
      wget https://kernel.ubuntu.com/mainline/v6.14-rc5/amd64/linux-modules-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb    
      ```
      >*user@nUbuntu2204:~/kernel$ wget https://kernel.ubuntu.com/mainline/v6.14-rc5/amd  
      64/linux-modules-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb  
      --2025-03-07 04:41:35--  https://kernel.ubuntu.com/mainline/v6.14-rc5/amd64/linux-modules-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb  
      Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 185.125.189.75, 185.125.189.76, 185.125.189.74  
      Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|185.125.189.75|:443... connected.  
      HTTP request sent, awaiting response... 200 OK  
      Length: 188651712 (180M) [application/x-debian-package]  
      Saving to: ‘linux-modules-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb’  
      linux-modules-6.14.0-06140 100%[======================================>] 179.91M  10.6MB/s    in 18s  
      2025-03-07 04:41:53 (10.2 MB/s) - ‘linux-modules-6.14.0-061400rc5-generic_6.14.0-061400rc5.202503022109_amd64.deb’ saved [188651712/188651712]*

    + устанавливаем все пакеты сразу
      ```
      sudo dpkg -i *.deb
      ```
      >*user@nUbunta2204:~/kernel$ sudo dpkg -i* *.deb  
      [sudo] password for user:  
      Selecting previously unselected package linux-headers-6.14.0-061400rc5.  
      (Reading database ... 74801 files and directories currently installed.)  
      Preparing to unpack linux-headers-6.14.0-061400rc5_6.14.0-061400rc5.202503022109_all.deb ...  
      Unpacking linux-headers-6.14.0-061400rc5 (6.14.0-061400rc5.202503022109)* ...

    + проверяем, что ядро появилось в */boot*.
      ```
      ls -al /boot
      ```
      >*user@nUbunta2204:~/kernel$ ls -al /boot
total 317484
drwxr-xr-x  3 root root      4096 Mar  7 08:58 .  
drwxr-xr-x 20 root root      4096 Mar  7 05:01 ..  
-rw-r--r--  1 root root    262228 Feb 12 18:47 config-5.15.0-134-generic  
-rw-r--r--  1 root root    295563 Mar  2 21:09 config-6.14.0-061400rc5-generic  
drwxr-xr-x  5 root root      4096 Mar  7 08:58 grub  
lrwxrwxrwx  1 root root        35 Mar  7 08:55 initrd.img -> initrd.img-6.14.0-0                  61400rc5-generic  
-rw-r--r--  1 root root 106292859 Mar  7 05:06 initrd.img-5.15.0-134-generic  
-rw-r--r--  1 root root 174548449 Mar  7 08:58 initrd.img-6.14.0-061400rc5-generic  
lrwxrwxrwx  1 root root        29 Mar  7 05:05 initrd.img.old -> initrd.img-5.15.0-134-generic 
-rw-------  1 root root   6295053 Feb 12 18:47 System.map-5.15.0-134-generic  
-rw-------  1 root root   9978944 Mar  2 21:09 System.map-6.14.0-061400rc5-generic  
lrwxrwxrwx  1 root root        32 Mar  7 08:55 vmlinuz -> vmlinuz-6.14.0-061400rc5-generic  
-rw-------  1 root root  11711336 Feb 12 19:36 vmlinuz-5.15.0-134-generic  
-rw-------  1 root root  15684096 Mar  2 21:09 vmlinuz-6.14.0-061400rc5-generic  
lrwxrwxrwx  1 root root        26 Mar  7 05:05 vmlinuz.old -> vmlinuz-5.15.0-134-generic*

    + обновляем конфигурацию загрузчика 
      ```
      sudo update-grub
      ```
      >*user@nUbunta2204:~/kernel$ sudo update-grub  
      [sudo] password for user:  
      Sourcing file `/etc/default/grub'  
      Sourcing file `/etc/default/grub.d/init-select.cfg'  
      Generating grub configuration file ...  
      Found linux image: /boot/vmlinuz-6.14.0-061400rc5-generic  
      Found initrd image: /boot/initrd.img-6.14.0-061400rc5-generic  
      Found linux image: /boot/vmlinuz-5.15.0-134-generic  
      Found initrd image: /boot/initrd.img-5.15.0-134-generic  
      Warning: os-prober will not be executed to detect other bootable partitions.  
      Systems on them will not be added to the GRUB boot configuration.  
      Check GRUB_DISABLE_OS_PROBER documentation entry.
      done*

    +  устанавливаем загрузку нового ядра по-умолчанию
       ```
       sudo grub-set-default 0
       ```
       >*user@nUbunta2204:~ /kernel$ sudo grub-set-default 0  
       user@nUbunta2204:~/kernel$*

    + перезагружаем систему
      ```
      reboot
      ```
    + проверяем версию ядра 
      ```
      uname -r
      ```
      >*user@nUbunta2204:~$ uname -r  
      6.14.0-061400rc5-generic*
     
7. **Вариант 2.** Собрать ядро из исходных кодов. **Debian 11.0.0**
  
    + проверяем версию ядра 
      ```
      uname -r
      ```
      >*user@vbox:~$ uname -r  
      5.10.0-34-686-pae*

    + открываем сайт [Kernel.org](https://kernel.org/) и копируем ссылку на архив исходников ядра **5.15.179**
      
    + переключаемся в суперпользователя
      ```
      su root
      ```
      >*user@vbox:~$ su root   
        Password:   
        root@vbox:/home/user#*

    +  добавляем репозиторий **http://ftp.de.debian.org/debian bullseye main** в файл */etc/apt/sources.list* и комментируем строки с названием *deb cdrom*.   
       ```
       nano /etc/apt/sources.list
       ```
       >*deb http://ftp.de.debian.org/debian bullseye main   
        #deb cdrom:[Debian GNU/Linux 11.0.0 _Bullseye_ - Official i386 DVD Binary-1 20210814-10:0   
        #deb cdrom:[Debian GNU/Linux 11.0.0 _Bullseye_ - Official i386 DVD Binary-1 20210814-10:0*
    + обновляем пакеты
      ```
      apt update
      ```
      >*root@vbox:/home/user# apt update   
       Hit:1 http://security.debian.org/debian-security bullseye-security InRelease
       Get:2 http://ftp.de.debian.org/debian bullseye InRelease [116 kB]
       Get:3 http://ftp.de.debian.org/debian bullseye/main i386 Packages [8,007 kB]
       Get:4 http://ftp.de.debian.org/debian bullseye/main Translation-en [6,235 kB]
       Fetched 14.4 MB in 11s (1,291 kB/s)
       Reading package lists... Done
       Building dependency tree... Done
       Reading state information... Done
       50 packages can be upgraded. Run 'apt list --upgradable' to see them.*

      ```
      apt-get dist-upgrade
      ```
      >*root@vbox:/home/user# apt-get dist-upgrade   
       Reading package lists... Done   
       Building dependency tree... Done   
       Reading state information... Done   
       Calculating upgrade... Done   
       The following packages will be upgraded:   
       adduser base-files bash cpio dbus debian-archive-keyring dpkg grep isc-dhcp-client isc-dhcp-common   
       libbsd0 libc-bin libc-l10n libc6 libdbus-1-3 libfreetype6 libgmp10 libncurses6 libncursesw6   
       libnftables1 libpam-modules libpam-modules-bin libpam-runtime libpam0g libpcre2-8-0 libseccomp2   
       libssh2-1 libtinfo6 locales logrotate nano ncurses-base ncurses-bin ncurses-term nftables publicsuffix         python3-idna python3-reportbug reportbug sysvinit-utils tar task-english task-ssh-server tasksel   
       tasksel-data traceroute vim-common vim-tiny wget xxd   
       50 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.   
       Need to get 23.6 MB of archives.   
       After this operation, 87.0 kB of additional disk space will be used.   
       Do you want to continue? [Y/n] y   
       Get:1 http://ftp.de.debian.org/debian bullseye/main i386 base-files i386 11.1+deb11u11 [70.2 kB]*

    + устанавливаем пакеты для компиляции ядра
      ```
      apt install make gcc libncurses-dev flex bison libssl-dev libelf-dev fakeroot rsync dpkg-dev bc screen -y
      ```
      >*root@vbox:/home/user# apt install make gcc libncurses-dev flex bison libssl-dev libelf-dev fakeroot    
        rsync dpkg-dev bc screen -y   
        Reading package lists... Done   
        Building dependency tree... Done   
        Reading state information... Done   
        The following additional packages will be installed:   
        binutils binutils-common binutils-i686-linux-gnu build-essential cpp cpp-10 dirmngr fontconfig-config          fonts-dejavu-core g++ g++-10 gcc-10 gnupg gnupg-l10n gnupg-utils gpg gpg-agent gpg-wks-client   
        gpg-wks-server gpgconf gpgsm libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl          libasan6 libassuan0 libatomic1 libbinutils libc-dev-bin libc-devtools libc6-dev libcc1-0 libcrypt-dev          libctf-nobfd0 libctf0 libdeflate0 libdpkg-perl libfakeroot libfile-fcntllock-perl libfl-dev libfl2   
        libfontconfig1 libgcc-10-dev libgd3 libgomp1 libisl23 libitm1 libjbig0 libjpeg62-turbo libksba8 libmpc3   
        libmpfr6 libnpth0 libnsl-dev libquadmath0 libsigsegv2 libstdc++-10-dev libtiff5 libtirpc-dev libubsan1   
        libutempter0 libwebp6 libxpm4 linux-libc-dev m4 manpages-dev patch pinentry-curses zlib1g-dev   
        Suggested packages:*

    + в каталоге */opt/* создаём папку **kernel** в которой будем компилировать ядро и сразу переходим в неё
      ```
      cd /opt/ ; mkdir kernel && cd kernel
      ```
      >*root@vbox:/home/user# cd /opt/ ; mkdir kernel && cd kernel   
        root@vbox:/opt/kernel#*

    + загружаем архив исходников ядра с помощью команды ***wget*** и используя сохраненную ссылку
      ```
      wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.179.tar.xz
      ```
      >*root@vbox:/opt/kernel# wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.179.tar.xz   
       --2025-03-22 13:23:56--  https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.179.tar.xz   
       Resolving cdn.kernel.org (cdn.kernel.org)... 151.101.85.176, 2a04:4e42:14::432   
       Connecting to cdn.kernel.org (cdn.kernel.org)|151.101.85.176|:443... connected.   
       HTTP request sent, awaiting response... 200 OK   
       Length: 126736344 (121M) [application/x-xz]   
       Saving to: ‘linux-5.15.179.tar.xz’   
       linux-5.15.179.tar.xz      100%[=======================================>] 120.86M  9.25MB/s    in 13s   
       2025-03-22 13:24:09 (9.52 MB/s) - ‘linux-5.15.179.tar.xz’ saved [126736344/126736344]*

    + разархивируем скачанный архив 
       ```
       tar xvf linux-5.15.179.tar.xz
       ```
       >*root@vbox:/opt/kernel# tar xvf linux-5.15.179.tar.xz   
        linux-5.15.179/   
        linux-5.15.179/.clang-format   
        linux-5.15.179/.cocciconfig   
        linux-5.15.179/.get_maintainer.ignore   
        linux-5.15.179/.gitattributes   
        linux-5.15.179/.gitignore   
        linux-5.15.179/.mailmap   
        linux-5.15.179/COPYING   
        linux-5.15.179/CREDITS   
        linux-5.15.179/Documentation/   
        linux-5.15.179/Documentation/.gitignore   
        linux-5.15.179/Documentation/ABI/   
        linux-5.15.179/Documentation/ABI/README   
        linux-5.15.179/Documentation/ABI/obsolete/   
        linux-5.15.179/Documentation/ABI/obsolete/sysfs-bus-iio   
        linux-5.15.179/Documentation/ABI/obsolete/sysfs-bus-usb   
        linux-5.15.179/Documentation/ABI/obsolete/sysfs-class-dax   
        linux-5.15.179/Documentation/ABI/obsolete/sysfs-class-typec   
        linux-5.15.179/Documentation/ABI/obsolete/sysfs-cpuidle   
        linux-5.15.179/Documentation/ABI/obsolete/sysfs-driver-hid-roccat-arvo   
        linux-5.15.179/Documentation/ABI/obsolete/sysfs-driver-hid-roccat-isku   
        linux-5.15.179/Documentation/ABI/obsolete/sysfs-driver-hid-roccat-koneplus   
        linux-5.15.179/Documentation/ABI/obsolete/sysfs-driver-hid-roccat-konepure   
        linux-5.15.179/Documentation/ABI/obsolete/sysfs-driver-hid-roccat-kovaplus*

    + переходим в каталог c распакованным архивом
      ```
      cd linux-5.15.179
      ```
      >*root@vbox:/opt/kernel# cd linux-5.15.179   
        root@vbox:/opt/kernel/linux-5.15.179#*

     
    + копируем конфигурацию текущего ядра
      ```
      cp /boot/config-5.10.0-34-686-pae ./.config
      ```
      >*root@vbox:/opt/kernel/linux-5.15.179# cp /boot/config-5.10.0-34-686-pae ./.config   
        root@vbox:/opt/kernel/linux-5.15.179#*

    + настраиваем функции и опции ядра (при необходимости) или оставляем всё по умолчанию 
      ```
      make menuconfig
      ```
      >*root@vbox:/opt/kernel/linux-5.15.179# make menuconfig   
       HOSTCC  scripts/basic/fixdep   
       UPD     scripts/kconfig/mconf-cfg   
       HOSTCC  scripts/kconfig/mconf.o   
       HOSTCC  scripts/kconfig/lxdialog/checklist.o   
       HOSTCC  scripts/kconfig/lxdialog/inputbox.o   
       HOSTCC  scripts/kconfig/lxdialog/menubox.o   
       HOSTCC  scripts/kconfig/lxdialog/textbox.o*

     + открываем редактором файл конфигурации ядра и удаляем или комментируем строки: *CONFIG_SYSTEM_TRUSTED_KEYRING=y,
CONFIG_SYSTEM_TRUSTED_KEYS="debian/canonical-certs.pem"* (отключаем использование доверенных серификатов). 
      ```
      nano .config
      ```
      >*root@vbox:/opt/kernel/linux-5.15.179# nano .config   
       root@vbox:/opt/kernel/linux-5.15.179#*
      
      >#CONFIG_SYSTEM_TRUSTED_KEYRING=y          
       #CONFIG_SYSTEM_TRUSTED_KEYS="debian/certs/debian-uefi-certs.pem"
   
    + запускаем сборку ядра
      ```
      make deb-pkg 
      ```
      >..........*ниже завершающийся этап сборки*............   
      *HDRINST usr/include/asm/errno.h   
      HDRINST usr/include/asm/ioctls.h   
      HDRINST usr/include/asm/unistd_64.h   
      HDRINST usr/include/asm/termios.h   
      HDRINST usr/include/asm/types.h   
      INSTALL debian/linux-libc-dev/usr/include   
      dpkg-deb: building package 'linux-libc-dev' in '../linux-libc-dev_5.15.179-1_i386.deb'.   
      dpkg-deb: building package 'linux-image-5.15.179' in '../linux-image-5.15.179_5.15.179-1_i386.deb'.   
      dpkg-deb: building package 'linux-image-5.15.179-dbg' in '../linux-image-5.15.179-dbg_5.15.179-1_i386.deb'.   
      dpkg-genbuildinfo   
      dpkg-genchanges  >../linux-upstream_5.15.179-1_i386.changes   
      dpkg-genchanges: info: including full source code in upload   
      dpkg-source -i.git --after-build .   
      dpkg-buildpackage: info: full upload (original source is included)*

    + после завершения компиляции ядра, переходим в родительский каталог и проверяем наличие *.deb*-пакетов.
      ```
      cd ..
      ```
      ```
      ls -l
      ```
      >*root@vbox:/opt/kernel/linux-5.15.179# cd ..   
        root@vbox:/opt/kernel# ls -l   
        total 1084720   
       drwxrwxr-x 26 root root      4096 Mar 22 22:55 linux-5.15.179   
       -rw-r--r--  1 root root 126736344 Mar 13 14:58 linux-5.15.179.tar.xz   
       -rw-r--r--  1 root root   8152472 Mar 22 22:59 linux-headers-5.15.179_5.15.179-1_i386.deb   
       -rw-r--r--  1 root root  47138488 Mar 22 23:01 linux-image-5.15.179_5.15.179-1_i386.deb   
       -rw-r--r--  1 root root 723431432 Mar 22 23:28 linux-image-5.15.179-dbg_5.15.179-1_i386.deb   
       -rw-r--r--  1 root root   1199688 Mar 22 22:59 linux-libc-dev_5.15.179-1_i386.deb   
       -rw-r--r--  1 root root    266425 Mar 22 14:52 linux-upstream_5.15.179-1.diff.gz   
       -rw-r--r--  1 root root      1133 Mar 22 14:52 linux-upstream_5.15.179-1.dsc   
       -rw-r--r--  1 root root      5656 Mar 22 23:28 linux-upstream_5.15.179-1_i386.buildinfo   
       -rw-r--r--  1 root root      3102 Mar 22 23:28 linux-upstream_5.15.179-1_i386.changes   
       -rw-r--r--  1 root root 203750285 Mar 22 14:51 linux-upstream_5.15.179.orig.tar.gz*   

    + устанавливаем все *.deb*-пакеты
      ```
      dpkg -i linux-*.deb
      ```
      >_root@vbox:/opt/kernel# dpkg -i linux-*.deb   
        Selecting previously unselected package linux-headers-5.15.179.   
       (Reading database ... 39839 files and directories currently installed.)   
        Preparing to unpack linux-headers-5.15.179_5.15.179-1_i386.deb ...   
        Unpacking linux-headers-5.15.179 (5.15.179-1) ...   
        Selecting previously unselected package linux-image-5.15.179.   
        Preparing to unpack linux-image-5.15.179_5.15.179-1_i386.deb ...   
        Unpacking linux-image-5.15.179 (5.15.179-1) ...   
        Selecting previously unselected package linux-image-5.15.179-dbg.   
        Preparing to unpack linux-image-5.15.179-dbg_5.15.179-1_i386.deb ...   
        Unpacking linux-image-5.15.179-dbg (5.15.179-1) ..._

    + **ВАЖНО!!!** Если команда не выполняется и появляется следующий текст,
      >_root@vbox:/opt/kernel# dpkg -i linux-*.deb   
       dpkg: warning: 'ldconfig' not found in PATH or not executable   
       dpkg: warning: 'start-stop-daemon' not found in PATH or not executable   
       dpkg: error: 2 expected programs not found in PATH or not executable   
       Note: root's PATH should usually contain /usr/local/sbin, /usr/sbin and /sbin_

      то необходимо в файл  */root/.bashrc* прописать строку *export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin*, перезагрузить систему и повторить повторно команду ___dpkg -i linux-*.deb___
      ```
      root@vbox:/opt/kernel# cd /root/
      ```
      ```
      root@vbox:~# nano .bashrc
      ```
      >_export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin   
       #~/.bashrc: executed by bash(1) for non-login shells.   
       #Note: PS1 and umask are already set in /etc/profile. You should not   
       #need this unless you want different defaults for root.   
       #PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '   
       #umask 022_
      
    + после успешной установки *.deb*-пакетов перезагружаем систему
      ```
      reboot
      ```
    + проверяем версию ядра 
      ```
      uname -r
      ```
      >*user@vbox:~$ uname -r   
        5.15.179*

   
