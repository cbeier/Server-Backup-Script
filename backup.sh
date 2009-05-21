#!/bin/bash

# Titel: Backup-Script 
# Description: Sicherung von /srv, /etc, /var/log und MYSQL-Datenbanken anlegen und automatisch auf einen festgelegten FTP-Server hochladen. 
# Copyright: Christian Beier (http://www.beier-christian.eu/) 
# Version 1.1


# Allgemeine Angaben
MYSQL_USER=Benutzername_fuer_MySQL_meistens_root
MYSQL_PASS=Passwort_fuer_MySQL
FTP_SERVER=Adresse_des_FTP-Servers_auf_dem_gesichert_werden_soll # Bsp. Strato: backup.serverkompetenz.de
FTP_USER=Benutzername
FTP_PASS=Passwort

# Festlegung des Datums - Format: 20050710
DATE=`date +"%Y%m%d"`

# ENDE DER EINSTELLUNGEN

# Backup-Verzeichnis anlegen 
mkdir /tmp/backup
mkdir /tmp/backup/mysql

# Verzeichnisse die ins Backup integriert werden sollen
cp -r /srv /tmp/backup
cp -r /etc /tmp/backup
cp -r /var/log /tmp/backup

cd /tmp/backup/mysql

# Sicherung der Datenbanken
mysqldump -AaCceQ -u$MYSQL_USER -p$MYSQL_PASS -r mysql.dbs

cd ../

# Alle Dateien mit tar.bz2 komprimieren
tar cjfp files-$DATE.tar.bz2 srv
tar cjfp etc-$DATE.tar.bz2 etc
tar cjfp logs-$DATE.tar.bz2 log
tar cjfp mysql-$DATE.tar.bz2 mysql

# Alle komprimierten Dateien per FTP auf den Backup-Server laden
ftp -ni << END_UPLOAD
  open $FTP_SERVER
  user $FTP_USER $FTP_PASS
  bin
  mput *.tar.bz2
  quit
END_UPLOAD

# Anschliessend alle auf den Server angelegten Dateien wieder loeschen
rm -r -f /tmp/backup