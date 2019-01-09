#!/bin/bash

# mount point
# ram size(mb)

#set -x

ramdisk__usage() {
	echo "ramdisk add|del|pers [args..]"
	echo ""
	echo "        add: add mount_point ram_size"
	echo "        del: del mount_point"
	echo "        pers: pers mount_point ram_size"
	echo ""
	echo "    mount_point is the path"
	echo "    ram_size is measured with MB"
}

ramdisk__create() {
	[ "$#" -ne 2 ] && ramdisk__usage && return 1

	mount_point=`realpath $1`
	ram_size=$2
	mount -t tmpfs -o size=${ram_size}m ext4 ${mount_point}
}

ramdisk__delete() {
	[ "$#" -ne 1 ] && ramdisk__usage && return 1

	mount_point=`realpath $1`
	umount ${mount_point}
	[ $? -eq 0 ] && cp /etc/fstab /etc/fstab.bk
	[ $? -eq 0 ] && cat /etc/fstab.bk | grep -v "${mount_point}" > /etc/fstab
}

ramdisk__persistent() {
	[ "$#" -ne 2 ] && ramdisk__usage && return 1

	mount_point=`realpath $1`
	ram_size=$2
	echo "ext4 ${mount_point} tmpfs nodev,nosuid,noexec,nodiratime,size=${ram_size}M 0 0" >> /etc/fstab
}

ramdisk__main() {
	if [ "$1" = "add" ];
	then
		shift && ramdisk__create $@
	elif [ "$1" = "del" ];
	then
		shift && ramdisk__delete $@
	elif [ "$1" = "pers" ];
	then
		shift && ramdisk__persistent $@
	else
		ramdisk__usage 
	fi
}

ramdisk() {
    if [ "Linux" = `uname -s` ];
    then
	    ramdisk__main $@
    else
        echo "not supported arch"
        return -1
    fi
}

ramdisk $@
