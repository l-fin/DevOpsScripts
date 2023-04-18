#!/bin/bash

# Set the path to the folder you want to backup
# BACKUP_PARENT_DIR="/var/lib/"
# BACKUP_DIR="jenkins"
BACKUP_PARENT_DIR="/home/ubuntu/rudy"
BACKUP_DIR="test_folder"

# Set the path to where you want to save the backups
DESTINATION_DIR="/home/ubuntu/rudy_backup_test"

# Set the path to where you want to save the log file
LOG_FILE="/home/ubuntu/rudy_backup_test/logfile.txt"

# Get the current date in the format we want for the backup filename
BACKUP_DATE=$(date +"%Y%m%d-%H%M%S")

# Create the backup filename
BACKUP_FILENAME="${BACKUP_DIR}_${BACKUP_DATE}.tar.gz"

# Get the MAX_KEEP_BACKUPS parameter or set the default value
MAX_KEEP_BACKUPS=${1:-10}

# Create the backup directory if it doesn't exist
if [ ! -d "${DESTINATION_DIR}" ]; then
  echo "Creating backup ${BACKUP_DIR} directory: ${DESTINATION_DIR}" >> "${LOG_FILE}"
  mkdir -p "${DESTINATION_DIR}"
fi

# Create the backup
echo "Creating backup: $BACKUP_FILENAME" >> "$LOG_FILE"
cd "${BACKUP_PARENT_DIR}"
pwd
tar cfz "${DESTINATION_DIR}/${BACKUP_FILENAME}" "./${BACKUP_DIR}"
backup_size=$(du -h "${DESTINATION_DIR}/${BACKUP_FILENAME}" | cut -f1)

if [ "$?" -eq 0 ]; then
  echo "Backup created successfully. File size: $backup_size" >> "$LOG_FILE"
else
  echo "Backup creation failed" >> "$LOG_FILE"
fi

# Delete backups if there are more than ${MAX_KEEP_BACKUPS} files in the backup directory
NUM_BACKUPS=$(ls -1 "${DESTINATION_DIR}"/*.tar.gz | wc -l)
echo ${NUM_BACKUPS}
if [ $NUM_BACKUPS -gt ${MAX_KEEP_BACKUPS} ]; then
  DELETE_COUNT=$((NUM_BACKUPS - ${MAX_KEEP_BACKUPS}))
  echo "Deleting old backups: ${DELETE_COUNT}" >> "$LOG_FILE"
  ls -1t "${DESTINATION_DIR}"/*.tar.gz | tail -$DELETE_COUNT | xargs rm --
fi
