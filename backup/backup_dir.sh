#!/bin/bash

# Set the path to the folder you want to backup
BACKUP_PARENT_DIR="/var/lib/"
BACKUP_DIR="jenkins"
TEMP_DIR="/tmp"


# Set the path to where you want to save the backups
DESTINATION_DIR="/mnt/nas01/jenkins/backup"

# Set the path to where you want to save the log file
LOG_FILE="/mnt/nas01/jenkins/backup/backupLogs.txt"

# Get the current date in the format we want for the backup filename # 20230419-142727
BACKUP_DATE=$(date +"%Y%m%d-%H%M%S")

# Create the backup filename
BACKUP_FILENAME="${BACKUP_DIR}_${BACKUP_DATE}.tar.gz"

# Get the MAX_KEEP_BACKUPS parameter or set the default value
MAX_KEEP_BACKUPS=${1:-10}

cores=$(nproc)

echo "Number of available cores: $cores"

# Create the backup directory if it doesn't exist
if [ ! -d "${DESTINATION_DIR}" ]; then
  echo "Creating backup ${BACKUP_DIR} directory: ${DESTINATION_DIR}" >> "${LOG_FILE}"
  mkdir -p "${DESTINATION_DIR}"
fi

# create temporary directory
TEMP_BACKUP_DIR=$(mktemp -d -p "${TEMP_DIR}")

# Create the backup
echo "Creating backup: $BACKUP_FILENAME" >> "$LOG_FILE"
cd "${BACKUP_PARENT_DIR}"
pwd
# tar -I 'pigz -p 8' -cvf "${TEMP_BACKUP_DIR}/${BACKUP_FILENAME}" "./${BACKUP_DIR}"
find "./${BACKUP_DIR}/tools/jenkins.plugins.nodejs.tools.NodeJSInstallation/" -type f > "${TEMP_BACKUP_DIR}/filelist.txt"
tar -I "pigz -p ${cores}" -cvf "${TEMP_BACKUP_DIR}/${BACKUP_FILENAME}" --files-from="${TEMP_BACKUP_DIR}/filelist.txt" --exclude='*/gradle' --exclude='*/node_modules' "./${BACKUP_DIR}"


# move backup from temporary to destination directory
cp --no-preserve=mode "${TEMP_BACKUP_DIR}/${BACKUP_FILENAME}" "${DESTINATION_DIR}/${BACKUP_FILENAME}"
rm -rf "${TEMP_BACKUP_DIR}"

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
~