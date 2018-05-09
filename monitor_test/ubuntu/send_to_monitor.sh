#!/bin/bash

url=http://monitor:5000
hostname=`hostname`
date=`date -Iseconds`
entry="{\"entry\":\"$1\", \"host\":\"$hostname\", \"date\":\"$date\"}"
curl -H "Content-type: application/json" \
     -X POST $url/log -d "$entry"
     
     
