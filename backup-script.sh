#!/bin/bash

# Variables
BACKUP_SRC="/home/ubuntu/bash"   # Path to the VM data to back up 
BACKUP_DEST="/home/ubuntu/backup"  # Local directory where backups will be stored 
S3_BUCKET="s3://s3-new-bash"  # S3 bucket to store backups 
DATE=$(date +"%Y-%m-%d_%H:%M")  # Organized date format (underscore for filename compatibility)
BACKUP_FILE="$BACKUP_DEST/backupfile-$DATE.tar.gz"
LOG_FILE="/home/ubuntu/backup/logfile.log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> $LOG_FILE
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    log_message "AWS CLI is not installed. Exiting."
    exit 1
fi

# Step 1: Create a backup (tar the VM data)
log_message "Starting backup process..."
tar -czf "$BACKUP_FILE" -C "$(dirname "$BACKUP_SRC")" "$(basename "$BACKUP_SRC")"  # Change to source directory

# Step 2: Check if the backup was successful
if [ $? -eq 0 ]; then
    log_message "Backup created successfully: $BACKUP_FILE"
    
    # Step 3: Upload the backup to S3
    log_message "Uploading backup to S3..."
    aws s3 cp "$BACKUP_FILE" "$S3_BUCKET"
    
    # Step 4: Check if the upload was successful
    if [ $? -eq 0 ]; then
        log_message "Backup uploaded successfully to $S3_BUCKET"
    else
        log_message "Error uploading backup to S3"
    fi
else
    log_message "Error creating backup"
fi

