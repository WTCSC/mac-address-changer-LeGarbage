#!/bin/bash

cat /sys/class/net/$1/address

ed -s test.txt <<EOF
a
Hello
World
I
am
a
text editor
.
w
q