#!/bin/bash

#Устанавливаем набор инструментов для работы с RPM
yum install -y wget rpmdevtools rpm-build createrepo yum-utils cmake gcc git nano lynx    
mkdir rpm && cd rpm
#Загружаем исходники пакета Nginx
yumdownloader --source nginx
#Устанавливаем пакет
rpm -Uvh nginx*.src.rpm 
#Устанавлиавем зависимости
yum-builddep nginx
cd /root
#Клонируем удаленный репозиторий на локальное устройство
git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli
cd ngx_brotli/deps/brotli && mkdir out && cd out
#Собираем модуль ngx_brotli
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..
cmake --build . --config Release -j 2 --target brotlienc
cd ../../../..
#Добавляем в конфигурацию srec-файла указание на модуль ngx_brotli
cd ~/rpmbuild/SPECS/
sed -i '312a\    --add-module=/root/ngx_brotli \\' /root/rpmbuild/SPECS/nginx.spec
#Сборка пакета RPM
rpmbuild -ba nginx.spec -D 'debug_package %{nil}'
#Копируем в общий каталог
cp ~/rpmbuild/RPMS/noarch/* ~/rpmbuild/RPMS/x86_64/
cd ~/rpmbuild/RPMS/x86_64
#Устанавливаем пакет из каталога
yum -y localinstall *.rpm
#Запускаем службу Nginx
systemctl start nginx
#Переходим к созданию своего репозитория
#Создаём папку и копируем в неё пакеты
mkdir /usr/share/nginx/html/repo
cp ~/rpmbuild/RPMS/x86_64/*.rpm /usr/share/nginx/html/repo/
#Инициализируем репозиторий
createrepo /usr/share/nginx/html/repo/
#Настраиваем в Nginx доступ к листингу каталога. 
sed -i '46a\        index  index.html index.htm;\' /etc/nginx/nginx.conf
sed -i '47a\        autoindex on;\' /etc/nginx/nginx.conf
nginx -t
#Перезапускаем Nginx.
nginx -s reload
#Изменяем конфигурационный файл репозиториев.
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo/
gpgcheck=0
enabled=1
EOF
#Устанавливаем пакет
yum repolist enabled | grep otus
cd /usr/share/nginx/html/repo/
#Скачиваем исходный код пакета percona-release
wget https://repo.percona.com/yum/percona-release-latest.noarch.rpm
#Обновляем список пакетов в репозитории.
createrepo /usr/share/nginx/html/repo/
yum makecache
#Устанавливаем новый пакет.
yum install -y percona-release.noarch
