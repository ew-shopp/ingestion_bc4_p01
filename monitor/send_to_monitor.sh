#!/bin/bash

url=http://"$1":8080
entry={\"entry\":\"$2\"} 
curl -H "Content-type: application/json" \
     -X POST $url/log -d "$entry"
     
     
