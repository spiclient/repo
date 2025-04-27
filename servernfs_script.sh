#!/bin/bash
#Устанавливаем компонент для сервера NFS
apt install nfs-kernel-server
#Создаём папку upload
mkdir -p /srv/share/upload
#Устанавливаем владельца. 
chown -R nobody:nogroup /srv/share
#Настраиваем доступ к каталогу upload
chmod 0777 /srv/share/upload
#Добавляем точку монтирования для экспортируемого каталога upload в файле exports.
cat << EOF > /etc/exports 
/srv/share 192.168.1.39(rw,sync,root_squash)
EOF
#Обновляем список
exportfs -r

				
	
