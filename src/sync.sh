#!/bin/bash

#set -e
#set -x

# echo -n "root@xxx.xxx.xxx.xxx" > ~/.remote
sync2remote__MIDDLE=`cat ~/.remote`
sync2remote__MIDDLEDIR="/tmp"

#TMPSH="/tmp/hehe.sh"
#MYSH="./my.sh"
#
#run_sh_in_middle() {
#    echo "$1" > $MYSH
#    cp $MYSH $TMPSH
#
#    scp $TMPSH $sync2remote__MIDDLE:$TMPSH
#    ssh $sync2remote__MIDDLE sh $TMPSH
#}

# mac os has no realpath :(
sync2remote__realpath() {
 if [ -d "$1" ];
 then
   echo $(cd "$1"; pwd)
 else
   dir=`dirname $1`
   file=`basename $1`
   echo $(cd ${dir}; pwd)/${file}
 fi
}

sync2remote__usage() {
    echo "sh sync.sh push|pull args..."
    echo "push:"
    echo "     push file|dir [anything] "
    echo "     anything is not null means push dir"
    echo "pull:"
    echo "     pull remotefile|remotedir localpath [anything] "
    echo "     anything is not null means pull dir"
}

sync2remote__push_file_to_middle() {
    #srcfile=$1
    #destpath=$2
    #basefile=`basename $srcfile`
    #dest=${destpath%%/}${destpath:+/}${basefile}
    #scp ${srcfile} ${sync2remote__MIDDLE}:${dest}

    srcfile=`realpath $1`
    base=`basename $srcfile`
    ssh ${sync2remote__MIDDLE} "rm -rf ${sync2remote__MIDDLEDIR}/${base}"
    scp ${srcfile} ${sync2remote__MIDDLE}:${sync2remote__MIDDLEDIR}/
}

sync2remote__pull_file_from_middle() {
    srcfile=`realpath $1`
    destpath=$2
    base=`basename ${srcfile}`
    scp ${sync2remote__MIDDLE}:${sync2remote__MIDDLEDIR}/${base} ${destpath}
}

sync2remote__push_dir_to_middle() {
    #srcdir=$1
    #destpath=$2
    #base=`basename $srcdir`
    #dest=${destpath%%/}${destpath:+/}${base}
    #scp -r ${srcdir} ${sync2remote__MIDDLE}:${dest}

    srcdir=`realpath $1`
    base=`basename $srcdir`
    ssh ${sync2remote__MIDDLE} "rm -rf ${sync2remote__MIDDLEDIR}/$base"
    scp -r ${srcdir} ${sync2remote__MIDDLE}:${sync2remote__MIDDLEDIR}/
}

sync2remote__pull_dir_from_middle() {
    srcdir=`realpath $1`
    destpath=$2
    base=`basename ${srcdir}`
    scp -r ${sync2remote__MIDDLE}:${sync2remote__MIDDLEDIR}/${base} ${destpath}
}

sync2remote__main() {
    if [ "$1" == "push" ];
    then
        # Push
        if [ "$#" -lt 2 ];
        then
            sync2remote__usage
            return 1
        elif [ "$3" != "" ];
        then
            sync2remote__push_dir_to_middle $2
        else
            sync2remote__push_file_to_middle $2
        fi
    elif [ "$1" == "pull" ];
    then
        # Pull
        if [ "$#" -lt 3 ];
        then
            sync2remote__usage
            return 1
        elif [ "$4" != "" ];
        then
            sync2remote__pull_dir_from_middle $2 $3
        else
            sync2remote__pull_file_from_middle $2 $3
        fi
    else
        sync2remote__usage
        return 1
    fi
}

sync2remote(){
    sync2remote__main $@
}

