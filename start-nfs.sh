#!/bin/bash
#cp /filesystem//config/exports /etc/exports # copy /etc/exports, just in case it has changed - admin would need to ensure they always copy files to shred filesystem
exportfs -a
service rpcbind start
service nfs start
#service smb start

exit 0
