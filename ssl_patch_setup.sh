#!/bin/bash

OPENSSL_FILE="/opt/xcat/share/xcat/ca/openssl.cnf.tmpl"
OPENSSL_BACKUP_FILE="/opt/xcat/share/xcat/ca/openssl.cnf.tmpl.orig"
DOCKERHOST_CERT_FILE="/opt/xcat/share/xcat/scripts/setup-dockerhost-cert.sh"
DOCKERHOST_CERT_BACKUP_FILE="/opt/xcat/share/xcat/scripts/setup-dockerhost-cert.sh.orig"

if [[ -f "$OPENSSL_FILE" ]]; then
  LOG "Backing up openssl template (if not already present): $OPENSSL_BACKUP_FILE"
  cp -n "$OPENSSL_FILE" "$OPENSSL_BACKUP_FILE" || LOG "Backup already exists."

  LOG "Commenting out lines starting with 'authorityKeyIdentifier' in $OPENSSL_FILE"
  # This will only comment lines that begin (optionally with whitespace) with authorityKeyIdentifier
  sed -i 's/^[[:space:]]*authorityKeyIdentifier/#&/' "$OPENSSL_FILE"
else
  LOG "OpenSSL template not found at $OPENSSL_FILE — skipping OpenSSL patch."
fi

if [[ -f "$DOCKERHOST_CERT_FILE" ]]; then
  LOG "Backing up $DOCKERHOST_CERT_FILE to $DOCKERHOST_CERT_BACKUP_FILE (no overwrite)"
  cp -n "$DOCKERHOST_CERT_FILE" "$DOCKERHOST_CERT_BACKUP_FILE" || LOG "Backup already exists."

  LOG "Removing '-extensions server' from the dockerhost openssl request line (if present)."
  # Only operate on the specific openssl req line to be safe
  sed -i '/openssl req -config ca\/openssl.cnf -new -key ca\/dockerhost-key.pem/ s/-extensions[[:space:]]*server[[:space:]]*//g' "$DOCKERHOST_CERT_FILE"

  # Show the updated line for verification
  LOG "Updated openssl req lines (matching file):"
  grep -n "openssl req -config ca/openssl.cnf" "$DOCKERHOST_CERT_FILE" || true
else
  LOG "File $DOCKERHOST_CERT_FILE not found — skipping dockerhost cert script patch."
fi
