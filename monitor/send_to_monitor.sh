#!/bin/bash

entry={\"entry\":\"$1\"} 
echo $entry
curl -H "Content-type: application/json" \
     -X POST http://localhost:5000/log -d "$entry"
     
     
