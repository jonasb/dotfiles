#!/bin/sh
source=$1
echo 'const unsigned char data[] = {'
od -txC -v ${source} |
	sed -e "s/^[0-9]*//" -e "s/ \([0-9a-f][0-9a-f]\)/0x\1,/g" -e"\$d"
echo '};'
