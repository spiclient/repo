#!/bin/bash
# Устанавливаем компоненты для работы с сетевой файловой системой(NFS)
sudo apt install nfs-common
# Добавляем в конфигурационный файл /etc/fstab точку монтирования, для автоматического монтирования.
echo "192.168.1.65:/srv/share/ /mnt nfs vers=3,noauto,x-systemd.automount 0 0" >> /etc/fstab
# Перезапускаем службу и конфигурацию
systemctl daemon-reload
systemctl restart remote-fs.target
				
