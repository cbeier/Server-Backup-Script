#!/bin/bash # Titel: Backup-Script 
# Description: Sicherung von /srv, /etc, /var/log und MYSQL-Datenbanken anlegen und automatisch auf einen festgelegten FTP-Server hochladen. 
# Copyright: Christian Beier (http://www.beier-christian.eu/) 
# Version 1.1


# Allgemeine Angaben

MYSQL_USER=[Benutzername für MySQL, meistens root]
MYSQL_PASS=[Passwort für MySQL]
FTP_SERVER=[Adresse des FTP-Servers auf dem gesichert werden soll - Strato: backup.serverkompetenz.de]
FTP_USER=[Benutzername]
FTP_PASS=[Passwort]

# Festlegung des Datums - Format: 20050710
DATE=`date +"%Y%m%d"`

# Das Script

# Backup-Verzeichnis anlegen 
mkdir /backup
mkdir /backup/mysql

# Verzeichnisse die ins Backup integriert werden sollen 
rsync -az --delete --delete-after /srv /backup
rsync -az --delete --delete-after /etc /backup
rsync -az --delete --delete-after /var/log /backup

cd /backup/mysql

# Sicherung der Datenbanken
mysqldump -AaCceQ -u$MYSQL_USER -p$MYSQL_PASS -r mysql.dbs

cd ../

# Alle Dateien mit tar.bz2 komprimieren
tar cjfp files-$DATE.tar.bz2 srv
tar cjfp etc-$DATE.tar.bz2 etc
tar cjfp logs-$DATE.tar.bz2 log
tar cjfp mysql-$DATE.tar.bz2 mysql

# Alle komprimierten Dateien per FTP auf den Backup-Server laden
ftp -u ftp://$FTP_USER:$FTP_PASS@$FTP_SERVER *$DATE*

# Anschließend alle auf den Server angelegten Dateien wieder löschen
rm -r -f /backup