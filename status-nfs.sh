#!/bin/bash
appresult=`service nfs status | grep nfsd | grep running | wc -l`
if [ "$appresult" == "1" ]; then
      echo  "ok"
fi

exit 0
