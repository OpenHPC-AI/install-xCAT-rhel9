#!/bin/bash

 OPENSSL_FILE=/opt/xcat/share/xcat/ca/openssl.cnf.tmpl
 OPENSSL_BACKUP_FILE=/opt/xcat/share/xcat/ca/openssl.cnf.tmpl.orig
 DOCKERHOST_CERT_FILE=/opt/xcat/share/xcat/scripts/setup-dockerhost-cert.sh
 DOCKERHOST_CERT_BACKUP_FILE=/opt/xcat/share/xcat/scripts/setup-dockerhost-cert.sh.orig
 xcat_version=latest

 wget https://raw.githubusercontent.com/xcat2/xcat-core/master/xCAT-server/share/xcat/tools/go-xcat -O /tmp/go-xcat && \
    chmod +x /tmp/go-xcat && \
    /tmp/go-xcat -x ${xcat_version} install -y && \
    # Backup + patch openssl template
    cp -n ${OPENSSL_FILE} ${OPENSSL_BACKUP_FILE} && \
    sed -i 's/^[[:space:]]*authorityKeyIdentifier/#&/' ${OPENSSL_FILE} && \
    # Backup + patch setup-dockerhost-cert.sh
    cp -n ${DOCKERHOST_CERT_FILE} ${DOCKERHOST_CERT_BACKUP_FILE} && \
    sed -i 's|openssl req -config ca/openssl.cnf -new -key ca/dockerhost-key.pem -out cert/dockerhost-req.pem -extensions server -subj "/CN=\$CNA"|openssl req -config ca/openssl.cnf -new -key ca/dockerhost-key.pem -out cert/dockerhost-req.pem -subj "/CN=\$CNA"|' ${DOCKERHOST_CERT_FILE}
# Reinitialize the xcat installation
    xcatconfig -i -c -s
# Source the profile to add xCAT commands to your path
    source /etc/profile.d/xcat.sh
# Restart the xcat service
    restartxcatd
