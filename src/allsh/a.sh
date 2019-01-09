#!/bin/bash

set -e
#set -x

CFG="./.ipconf"

cp_usage() {
    echo "    cp src dest ips..."
    echo "        copy file|dir to remote"
    echo ""
    echo "        src:    local path"
    echo "        dest:   remote path, must be a dir path, if no will create"
    echo "        ips:    specified ips"
    echo ""
}

ss_usage() {
	echo "    ss [-c] ips..."
    echo "        build no passwd ssh"
    echo ""
    echo "        -c:     ALWAYS CREATE CERTS in ~/.ssh when add cert"
    echo "        ips:    specified ips"
    echo ""
}

do_usage() {
    echo "    do ips..."
    echo "        do do.sh in remote"
    echo ""
    echo "        ips:    specified ips"
    echo ""
}

usage() {
    echo "sh a.sh ss|cp|do ..."
    echo ""
    ss_usage
    cp_usage
    do_usage
} 

getip() {
    v="ip_$1"
    echo ${!v}
}

showips() {
    echo "-----------------------------------------"
    echo "All ips:"
    declare | grep ip_ | sed 's/^ip_/    /g' | sed 's/=/ =\> /g'
    echo ""
    echo "-----------------------------------------"
}

showselected() {
    echo "Aims are: "$@
    echo ""
    printf "Go on press enter: "
    read -n1 ans
    [ "${ans}" != "" ] && echo "" && exit 
    echo ${ans}
}

filter_error_target() {
    [[ ! "$2" =~ ^.*\@[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] && echo "skip $1 => $2, error target\n" && return 1
    return 0
}

ass() {
    [ $# -eq 0 ] && ss_usage && return 1

    if [ "$1" == "-c" ];
    then
        echo "ss warn: deleting old key in ~/.ssh"
    	rm -rf ~/.ssh/id_rsa
    	rm -rf ~/.ssh/id_rsa.pub
        shift
    fi
    
    showselected $@
    for i in $@
    do
        echo "........................................."

        I=`getip $i`
        filter_error_target ${i} ${I} || continue

        # copy pub key to remote
        echo "${i} => ${I}\n"
        if [ -f ~/.ssh/id_rsa ] && [ -f ~/.ssh/id_rsa.pub ];
        then
        	ssh-copy-id -i ~/.ssh/id_rsa.pub $I
        else
        	echo "no key, create id_rsa.pub first"
            ssh-keygen<<EOF

EOF
        	ssh-copy-id -i ~/.ssh/id_rsa.pub $I
        fi

        echo ""
    done
}

acp() {
    # check arg num
    [ "$#" -lt 3 ] && cp_usage && return 1

    SRC=$1
    DEST=$2

    # check src exist
    [[ ! -a "$SRC" ]] && echo "cp's src \"${SRC}\" not exist" && return 1

    shift
    shift

    showselected $@
    for i in $@
    do
        echo "........................................."

        I=`getip $i`
        filter_error_target ${i} ${I} || continue

        echo "${i} => ${I}\n"
        flag="" && [ -d ${SRC} ] && flag="-r"
        ssh ${I} "mkdir -p ${DEST}"
        scp ${flag} ${SRC} ${I}:${DEST} 

        echo ""
    done
}

ado() {
    [ $# -eq 0 ] && do_usage && return 1

    DOSH="do.sh"

    showselected $@
    for i in $@
    do
        echo "........................................."

        I=`getip $i`
        filter_error_target ${i} ${I} || continue

        echo "${i} => ${I}\n"
        scp $DOSH $I:/tmp >/dev/null 
        [ $? -ne 0 ] && echo "transfer do script to ${i} => ${I} error, skip" && continue
        ssh $I "sh /tmp/$DOSH"

        echo ""
    done
}

main() {
    [ "$#" -eq 0 ] && usage && return 1

    #parse_args
    touch $CFG
    cat $CFG | grep -v -e "^$" | grep -v -e "#.*" | awk '{printf("declare ip_%s=%s\n", $1, $2)}' > .tmp
    . .tmp

    showips
    
    if [ "$1" = "cp" ];
    then
        shift
        acp $@ || return 1
    elif [ "$1" = "do" ];
    then
        shift
        ado $@ || return 1
    elif [ "$1" = "ss" ];
    then
        shift
        ass $@ || return 1
    else
        usage && return 1
    fi
}

main $@
