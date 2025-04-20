#!/bin/bash
# Устанавливаем утилиты для работы с ZFS
apt install zfsutils-linux
# Создаём 4 пула  из 2 дисков в режиме зеркального RAID1
zpool create poollzjb mirror /dev/sdb /dev/sdc
zpool create poollz4 mirror /dev/sdd /dev/sde
zpool create poolgzip mirror /dev/sdf /dev/sdg
zpool create poolzle mirror /dev/sdh /dev/sdi
# На каждый пул устанавливаем определенный алгоритм сжатия - lzjb, lz4, gzip-9, zle.
zfs set compression=lzjb poollzjb
zfs set compression=zle poolzle
zfs set compression=lz4 poollz4
zfs set compression=gzip-9 poolgzip
# Выводим информацию о методах сжатия на пулах.
zfs get all | grep compression
