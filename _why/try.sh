#!/bin/sh
tryurl="http://tryruby.hobix.com/irb?cmd="
wget="wget -q -O -"
sess="$($wget "$tryurl!INIT!IRB!")"
if [ -z "$sess" ] ; then
    wget="curl -s"
    sess="$($wget "$tryurl!INIT!IRB!")"
fi
 
# heshugly url encoding
urlx() {
    echo "$*" |
    awk 'BEGIN { split("1 2 3 4 5 6 7 8 9 A B C D E F", het, " ");het[0] = 0
    for (i = 1; i <= 255; ++i) ord[ sprintf ("%c", i) "" ] = i + 0;}{
    enx = "";for (i = 1; i <= length($0); ++i ) {c = substr ($0, i, 1);val = ord[c]
    if (val >= 97 && val <= 122){enx = enx c}else if (val >= 65 && val <= 90){
    enx = enx c}else if (val >= 48 && val <= 57){enx = enx c}else if (val >= 45 && 
    val <= 46){enx = enx c}else if (c == " "){enx = enx "+"}else if (val < 128) {
    lo = val % 16;hi = int(val / 16);enx = enx "%" het[hi] het[lo];}else{byte = \
    192 + val/64;lo = byte % 16;hi = int(byte / 16);enx = enx "%" het[hi] het[lo];
    byte = 128 + val%64;lo = byte % 16;hi = int(byte / 16)
    enx = enx "%" het[hi] het[lo]}}print enx}'
}

# the prompt!
echo "Interactive Ruby ready."
echo -n ">> "
while read cmd
do
    resp=""; ps=">>"
    if [ -n "$cmd" ] ; then
        resp="$($wget --header "Cookie: _session_id=$sess" "$tryurl$(urlx "$cmd")")"
        ps=".."
        if [ -n "$resp" ] ; then
            echo $resp
            ps=">>"
        fi
    fi
    echo -n "$ps "
done
