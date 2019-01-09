#!/bin/bash

add_ssh_cert__usage() {
	echo "Script for add ssh/scp cert to remotehost, default is TRY USING EXISTING CERTS in ~/.ssh when add cert"
    echo ""
	echo -e "-c:\tALWAYS CREATE CERTS in ~/.ssh when add cert"
	echo -e "-h:\tshow this help"
	echo ""
	echo "================================================"
	echo "./add-cert.sh [-c|-h] user@xxx.xxx.xxx.xxx alias"
	echo "================================================"
}

add_ssh_cert__main() {
    if [ $# -ne 1 ] && [ $# -ne 2 ] && [ $# -ne 3 ] || [ $1 == "-h" ];
    then
        add_ssh_cert__usage
    	return 1
    fi
    
    REMOTEHOST=""
    ALIAS=""
    if [ $# -eq 1 ];
    then
    	REMOTEHOST=$1
    elif [ $# -eq 2 ] && [ "$1" == "-c" ];
    then
    	REMOTEHOST=$2
    elif [ $# -eq 2 ];
    then
    	REMOTEHOST=$1
    	ALIAS=$2
    elif [ $# -eq 3 ];
    then
    	REMOTEHOST=$2
    	ALIAS=$3
    fi
    
    echo "[add-cert] add certs to $REMOTEHOST"
    
    if [ $1 == "-c" ];
    then
    	rm -rf ~/.ssh/id_rsa
    	rm -rf ~/.ssh/id_rsa.pub
    fi
    
    if [ -f ~/.ssh/id_rsa ] && [ -f ~/.ssh/id_rsa.pub ];
    then
    	ssh-copy-id -i ~/.ssh/id_rsa.pub $REMOTEHOST
    else
    	echo "[add-cert] create rsa first"
        ssh-keygen<<EOF

EOF
    	ssh-copy-id -i ~/.ssh/id_rsa.pub $REMOTEHOST
    fi
    
    if [ "${ALIAS}" != "" ];
    then
    	echo "Now install alias"
    	echo "alias ${ALIAS}=\"ssh ${REMOTEHOST}\"" >> ~/.bash_profile
    #	source ~/.bash_profile
    	echo "you can try alias ${ALIAS} now"
    fi
}

add_ssh_cert() {
    add_ssh_cert__main $@
}

