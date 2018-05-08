#!/bin/bash

entry={\"entry\":\"$1\"} 
echo $entry
curl -H "Content-type: application/json" \
     -X POST http://localhost:8080/log -d "$entry"
     
     
