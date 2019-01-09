#!/bin/bash

for i in src/*.sh
do
    #echo $i
    . $i
done

if [ `uname -s` = "Linux" ]
then
    for i in src/linux_only/*.sh
    do
        . $i
    done
fi

