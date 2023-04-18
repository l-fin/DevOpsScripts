#!/bin/bash

# Set the path to the folder you want to backup
# BACKUP_PATH="/var/lib/"
# BACKUP_FOLDER_NAME="jenkins"
BACKUP_PATH="/home/ubuntu/rudy"
BACKUP_FOLDER_NAME="test_folder"

# Set the path to where you want to save the backups
BACKUP_DIR="/home/ubuntu/rudy_backup_test"

# Set the path to where you want to save the log file
LOG_FILE="/home/ubuntu/rudy_backup_test/logfile.txt"

# Create the backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
  echo "Creating backup jenkins directory: $BACKUP_DIR" >> "$LOG_FILE"
  mkdir -p "$BACKUP_DIR"
fi

# Get the current date in the format we want for the backup filename
BACKUP_DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Create the backup filename
BACKUP_FILENAME="${BACKUP_FOLDER_NAME}_${BACKUP_DATE}.tar.gz"

# Create the backup
echo "Creating backup: $BACKUP_FILENAME" >> "$LOG_FILE"
cd "${BACKUP_PATH}"
pwd
tar cfz "${BACKUP_DIR}/${BACKUP_FILENAME}" "./$BACKUP_FOLDER_NAME"


# Delete backups if there are more than 5 files in the backup directory
NUM_BACKUPS=$(ls -1 "$BACKUP_DIR"/*.tar.gz | wc -l)
if [ $NUM_BACKUPS -gt 10 ]; then
  echo "Deleting old backups" >> "$LOG_FILE"
  DELETE_COUNT=$((NUM_BACKUPS - 5))
  ls -1t "$BACKUP_DIR"/*.tar.gz | tail -$DELETE_COUNT | xargs rm --
fi
