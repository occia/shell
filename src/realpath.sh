#!/bin/bash

# realpath in mac os
 
realpath() {
 [ "$1" = "" ] && return 1

 dir=`dirname "$1"`
 file=`basename "$1"`

 last=`pwd`

 [ -d "$dir" ] && cd $dir || return 1
 if [ -d "$file" ];
 then
   # case 1
   cd $file && pwd || return 1
 else
   # case 2
   echo `pwd`/$file | sed 's/\/\//\//g'
 fi

 cd $last
}
