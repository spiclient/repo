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
     
   
9. Скачиваем исходный код модуля **ngx_brotli**, через создание полной копии удаленного репозитория на локальном устройстве.
   a. переходим в корневой каталог
   ```
   cd /root
   ```
   b. клонируем репозиторий
   ```
   git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli
   ```
   >*[root@Almalinux ~]# git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli   
Cloning into 'ngx_brotli'...   
remote: Enumerating objects: 237, done.   
remote: Counting objects: 100% (37/37), done.   
remote: Compressing objects: 100% (16/16), done.   
remote: Total 237 (delta 24), reused 21 (delta 21), pack-reused 200 (from 1)   
Receiving objects: 100% (237/237), 79.51 KiB | 768.00 KiB/s, done.   
Resolving deltas: 100% (114/114), done.   
Submodule 'deps/brotli' (https://github.com/google/brotli.git) registered for path 'deps/brotli'   
Cloning into '/root/ngx_brotli/deps/brotli'...   
remote: Enumerating objects: 7810, done.   
remote: Counting objects: 100% (27/27), done.   
remote: Compressing objects: 100% (26/26), done.   
remote: Total 7810 (delta 10), reused 1 (delta 1), pack-reused 7783 (from 2)   
Receiving objects: 100% (7810/7810), 40.62 MiB | 2.25 MiB/s, done.   
Resolving deltas: 100% (5069/5069), done.   
Submodule path 'deps/brotli': checked out 'ed738e842d2fbdf2d6459e39267a633c4a9b2f5d'*   
 
10. Создаём папку **out** в каталоге ***root/ngx_brotli/deps/brotli***
    ```
    cd ngx_brotli/deps/brotli && mkdir out && cd out
    ```
    >*[root@Almalinux ~]# cd ngx_brotli/deps/brotli && mkdir out && cd out*
    
11. Собираем модуль **ngx_brotli**.
    ```
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..
    ```
    >*[root@Almalinux out]# cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..   
-- The C compiler identification is GNU 11.5.0   
-- Detecting C compiler ABI info   
-- Detecting C compiler ABI info - done   
-- Check for working C compiler: /usr/bin/cc - skipped   
-- Detecting C compile features   
-- Detecting C compile features - done   
-- Build type is 'Release'   
-- Performing Test BROTLI_EMSCRIPTEN   
-- Performing Test BROTLI_EMSCRIPTEN - Failed   
-- Compiler is not EMSCRIPTEN    
-- Looking for log2   
-- Looking for log2 - not found   
-- Looking for log2   
-- Looking for log2 - found   
-- Configuring done (1.6s)   
-- Generating done (0.1s)*
    ```
    cmake --build . --config Release -j 2 --target brotlienc
    ```
    >*[root@Almalinux out]# cmake --build . --config Release -j 2 --target brotlienc   
[  6%] Building C object CMakeFiles/brotlicommon.dir/c/common/constants.c.o   
[  6%] Building C object CMakeFiles/brotlicommon.dir/c/common/context.c.o   
[ 10%] Building C object CMakeFiles/brotlicommon.dir/c/common/dictionary.c.o   
[ 13%] Building C object CMakeFiles/brotlicommon.dir/c/common/platform.c.o   
[ 17%] Building C object CMakeFiles/brotlicommon.dir/c/common/shared_dictionary.c.o   
[ 20%] Building C object CMakeFiles/brotlicommon.dir/c/common/transform.c.o    
[ 24%] Linking C static library libbrotlicommon.a    
[ 24%] Built target brotlicommon   
[ 31%] Building C object CMakeFiles/brotlienc.dir/c/enc/backward_references_hq.c.o   
[ 31%] Building C object CMakeFiles/brotlienc.dir/c/enc/backward_references.c.o   
[ 34%] Building C object CMakeFiles/brotlienc.dir/c/enc/bit_cost.c.o   
[ 37%] Building C object CMakeFiles/brotlienc.dir/c/enc/block_splitter.c.o   
[ 41%] Building C object CMakeFiles/brotlienc.dir/c/enc/brotli_bit_stream.c.o   
[ 44%] Building C object CMakeFiles/brotlienc.dir/c/enc/cluster.c.o   
[ 48%] Building C object CMakeFiles/brotlienc.dir/c/enc/command.c.o   
[ 51%] Building C object CMakeFiles/brotlienc.dir/c/enc/compound_dictionary.c.o   
[ 55%] Building C object CMakeFiles/brotlienc.dir/c/enc/compress_fragment.c.o   
[ 58%] Building C object CMakeFiles/brotlienc.dir/c/enc/compress_fragment_two_pass.c.o   
[ 62%] Building C object CMakeFiles/brotlienc.dir/c/enc/dictionary_hash.c.o   
[ 65%] Building C object CMakeFiles/brotlienc.dir/c/enc/encode.c.o   
[ 68%] Building C object CMakeFiles/brotlienc.dir/c/enc/encoder_dict.c.o   
[ 72%] Building C object CMakeFiles/brotlienc.dir/c/enc/entropy_encode.c.o   
[ 75%] Building C object CMakeFiles/brotlienc.dir/c/enc/fast_log.c.o   
[ 79%] Building C object CMakeFiles/brotlienc.dir/c/enc/histogram.c.o   
[ 82%] Building C object CMakeFiles/brotlienc.dir/c/enc/literal_cost.c.o   
[ 86%] Building C object CMakeFiles/brotlienc.dir/c/enc/memory.c.o   
[ 89%] Building C object CMakeFiles/brotlienc.dir/c/enc/metablock.c.o   
[ 93%] Building C object CMakeFiles/brotlienc.dir/c/enc/static_dict.c.o   
[ 96%] Building C object CMakeFiles/brotlienc.dir/c/enc/utf8_util.c.o   
[100%] Linking C static library libbrotlienc.a   
[100%] Built target brotlienc*   

  
12. Для того, чтобы Nginx собирался с необходимыми нам опциями, правим **spec**-файл. Изменение вносим в секцию с параметрами **configure**(до условий *if*), добавляем указание на модуль и в конце ставим обратный слэш(*--add-module=/root/ngx_brotli* \\).
    ```
    cd ~/rpmbuild/SPECS/ && nano nginx.spec
    ```
    >*if ! ./configure \   
    --prefix=%{_datadir}/nginx \   
    --sbin-path=%{_sbindir}/nginx \   
    --modules-path=%{nginx_moduledir} \   
    --conf-path=%{_sysconfdir}/nginx/nginx.conf \   
    --error-log-path=%{_localstatedir}/log/nginx/error.log \   
    --http-log-path=%{_localstatedir}/log/nginx/access.log \   
    --http-client-body-temp-path=%{_localstatedir}/lib/nginx/tmp/client_body \   
    --http-proxy-temp-path=%{_localstatedir}/lib/nginx/tmp/proxy \   
    --http-fastcgi-temp-path=%{_localstatedir}/lib/nginx/tmp/fastcgi \   
    --http-uwsgi-temp-path=%{_localstatedir}/lib/nginx/tmp/uwsgi \   
    --http-scgi-temp-path=%{_localstatedir}/lib/nginx/tmp/scgi \   
    --pid-path=/run/nginx.pid \   
    --lock-path=/run/lock/subsys/nginx \   
    --user=%{nginx_user} \   
    --group=%{nginx_user} \    
    --with-compat \   
    --with-debug \   
    <mark>--add-module=/root/ngx_brotli \\</mark>*   
    %if 0%{?with_aio}   

    

    
13. Приступаем к сборке RPM-пакета.
    ```
    rpmbuild -ba nginx.spec -D 'debug_package %{nil}'
    ```
    >*[root@Almalinux SPECS]# rpmbuild -ba nginx.spec -D 'debug_package %{nil}'   
setting SOURCE_DATE_EPOCH=1727654400   
Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.kgos10       
\+ umask 022   
\+ cd /root/rpmbuild/BUILD   
\+ cat /root/rpmbuild/SOURCES/maxim.key /root/rpmbuild/SOURCES/mdounin.key /root/rpmbuild/SOURCES/sb.key   
\+ /usr/lib/rpm/redhat/gpgverify --keyring=/root/rpmbuild/BUILD/nginx.gpg --signature=/root/rpmbuild/SOURCES/nginx-1.20.1.tar.gz.asc --
data=/root/rpmbuild/SOURCES/nginx-1.20.1.tar.gz   
gpgv: Signature made Tue May 25 15:42:56 2021 MSK   
gpgv:                using RSA key 520A9993A1C052F8   
gpgv: Good signature from "Maxim Dounin <mdounin@mdounin.ru>"   
\+ cd /root/rpmbuild/BUILD   
\+ rm -rf nginx-1.20.1   
\+ /usr/bin/gzip -dc /root/rpmbuild/SOURCES/nginx-1.20.1.tar.gz   
\+ /usr/bin/tar -xof -   
\+ STATUS=0    
\+ '[' 0 -ne 0 ']'    
\+ cd nginx-1.20.1    
\+ /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w .   
\+ /usr/bin/cat /root/rpmbuild/SOURCES/0001-remove-Werror-in-upstream-build-scripts.patch   
\+ /usr/bin/patch -p1 -s --fuzz=0 --no-backup-if-mismatch   
\+ /usr/bin/cat /root/rpmbuild/SOURCES/0002-fix-PIDFile-handling.patch   
\+ /usr/bin/patch -p1 -s --fuzz=0 --no-backup-if-mismatch*   
----------------------------и т.д.------------------------------   
*Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.bemlYS   
\+ umask 022   
\+ cd /root/rpmbuild/BUILD   
\+ cd nginx-1.20.1   
\+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/nginx-1.20.1-20.el9.alma.1.x86_64   
\+ RPM_EC=0   
\++ jobs -p   
\+ exit 0*   

    
14. Смотрим содержимое каталога */root/rpmbuild/RPMS/x86_64*
    ```
    ll /root/rpmbuild/RPMS/x86_64
    ```
    >*[root@Almalinux SPECS]# *ll /root/rpmbuild/RPMS/x86_64   
total 1992   
-rw-r--r--. 1 root root   36242 May  4 12:02 nginx-1.20.1-20.el9.alma.1.x86_64.rpm   
-rw-r--r--. 1 root root 1025551 May  4 12:02 nginx-core-1.20.1-20.el9.alma.1.x86_64.rpm   
-rw-r--r--. 1 root root  759818 May  4 12:02 nginx-mod-devel-1.20.1-20.el9.alma.1.x86_64.rpm   
-rw-r--r--. 1 root root   19367 May  4 12:02 nginx-mod-http-image-filter-1.20.1-20.el9.alma.1.x86_64.rpm   
-rw-r--r--. 1 root root   31015 May  4 12:02 nginx-mod-http-perl-1.20.1-20.el9.alma.1.x86_64.rpm   
-rw-r--r--. 1 root root   18174 May  4 12:02 nginx-mod-http-xslt-filter-1.20.1-20.el9.alma.1.x86_64.rpm   
-rw-r--r--. 1 root root   53822 May  4 12:02 nginx-mod-mail-1.20.1-20.el9.alma.1.x86_64.rpm   
-rw-r--r--. 1 root root   80437 May  4 12:02 nginx-mod-stream-1.20.1-20.el9.alma.1.x86_64.rpm*   

15. Копируем содержимое */root/rpmbuild/RPMS/noarch* в общий каталог.
    ```
    cp ~/rpmbuild/RPMS/noarch/* ~/rpmbuild/RPMS/x86_64/
    ```
    >_[root@Almalinux ~]# cp ~/rpmbuild/RPMS/noarch/* ~/rpmbuild/RPMS/x86_64/_

16. Устанавливаем пакет из каталога */root/rpmbuild/RPMS/x86_64/* и проверяем работу **Nginx**.
    ```
    yum localinstall *.rpm
    ```
    >*[root@Almalinux x86_64]# yum localinstall *.rpm
Last metadata expiration check: 1:34:28 ago on Sun May  4 11:06:48 2025.
Dependencies resolved.*
    <pre>==========================================================================================================================
          Package                                Architecture      Version                           Repository               Size
         ==========================================================================================================================
         Installing:
          nginx                                  x86_64            2:1.20.1-20.el9.alma.1            @commandline             35 k
          nginx-all-modules                      noarch            2:1.20.1-20.el9.alma.1            @commandline            7.2 k
          nginx-core                             x86_64            2:1.20.1-20.el9.alma.1            @commandline            1.0 M
          nginx-filesystem                       noarch            2:1.20.1-20.el9.alma.1            @commandline            8.2 k
          nginx-mod-devel                        x86_64            2:1.20.1-20.el9.alma.1            @commandline            742 k
          nginx-mod-http-image-filter            x86_64            2:1.20.1-20.el9.alma.1            @commandline             19 k
          nginx-mod-http-perl                    x86_64            2:1.20.1-20.el9.alma.1            @commandline             30 k
          nginx-mod-http-xslt-filter             x86_64            2:1.20.1-20.el9.alma.1            @commandline             18 k
          nginx-mod-mail                         x86_64            2:1.20.1-20.el9.alma.1            @commandline             53 k
          nginx-mod-stream                       x86_64            2:1.20.1-20.el9.alma.1            @commandline             79 k
         Installing dependencies:
          almalinux-logos-httpd                  noarch            90.5.1-1.1.el9                    appstream                18 k
         ==========================================================================================================================
         Install  11 Packages
         ---------и т.д.-----------
         Installed:
           almalinux-logos-httpd-90.5.1-1.1.el9.noarch                     nginx-2:1.20.1-20.el9.alma.1.x86_64
           nginx-all-modules-2:1.20.1-20.el9.alma.1.noarch                 nginx-core-2:1.20.1-20.el9.alma.1.x86_64
           nginx-filesystem-2:1.20.1-20.el9.alma.1.noarch                  nginx-mod-devel-2:1.20.1-20.el9.alma.1.x86_64
           nginx-mod-http-image-filter-2:1.20.1-20.el9.alma.1.x86_64       nginx-mod-http-perl-2:1.20.1-20.el9.alma.1.x86_64
           nginx-mod-http-xslt-filter-2:1.20.1-20.el9.alma.1.x86_64        nginx-mod-mail-2:1.20.1-20.el9.alma.1.x86_64
           nginx-mod-stream-2:1.20.1-20.el9.alma.1.x86_64
         Complete!
    </pre>
17. lilyiul



