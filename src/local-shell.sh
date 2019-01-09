say_sth_now() {
    for i in {1..100}
    do 
        say $1
    done
}

say_sth() {
    sleep $(( $1 * 60 ))
    say_sth_now $2
}

cppaper2dir() {
    RIS=$1
    DIR=$2
    mkdir $DIR || return -1
    [ -f "$RIS" ] || return -1
    cat $RIS | grep "file:///" | awk -F "file://" '{print $2}' | while read f; do [ -f "$f" ] && cp "$f" $DIR || echo non-exist:$f ; done
}
