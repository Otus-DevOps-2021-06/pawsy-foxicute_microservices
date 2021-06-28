#!/bin/bash
yc compute instance list | awk '{print $4 "\t" $12}' | sed '/[0-9]/!d' | tee hosts.txt
