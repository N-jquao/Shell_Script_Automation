## I created a bash shell script that automates the backup of files in a specified directory, carries out file integrity checks on the backed-up file and notifies the system admin when a backup is completed

#!/bin/bash

# === CONFIGURATION ===

SOURCE_DIR="home/linux"
BACKUP_DIR="/backups"
LOG_DIR="/var/log"
RETENTION_DAYS=7
BACKUP_LOG="/var/log/backup_script.log"

# Using tar to compress the source directory into a timestamped archive

backup() {
  TIMESTAMP=$(date)
  BACKUP_FILE="$BACKUP_DIR/project_backup_$TIMESTAMP.tar.gz"
  
  echo "[$(date)] Starting backup..." >> "$BACKUP_LOG"
  tar -czf "$BACKUP_FILE" "$SOURCE_DIR" 2>> "BACKUP_LOG"
  
  if [ $? -eq 0 ]; then
    echo "[$(date) Backup successful: $BACKUP_FILE" >>"$BACKUP_LOG"
  else
    echo "[$(date) Backup failed!" >> "$BACKUP_LOG"
    exit 1
  fi
}

backup


# Adding a file integrity check

integrity() {
  sha256sum "$BACKUP_FILE" > "BACKUP_FILE.sha256"
  echo "[$(date)] Integrity has generated." >> "BACKUP_LOG"
}

integrity


# Deleting backups older than 7 days

cleanup_old_backups() {
  find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +$RETENTION_DAYS -exec rm {} \;
  echo "[$(date)] Old backups cleaned." >> "BACKUP_LOG"
}

cleanup_old_backups


# Sending an email to notify system administrator when a backup has completed

notify() {
  mail -s "Backup Completed" user@email.com < "$BACKUP_LOG"
}

notify
