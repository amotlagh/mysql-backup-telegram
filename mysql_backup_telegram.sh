#!/bin/bash

# Script Name: MySQL Backup Telegram
# Version: 1.0
# Author: drhdev
# Description: This script performs a backup of a specified MySQL database, compresses the backup,
#              manages the retention of a specified number of backups and log files, logs its operations,
#              and sends a success or failure message to a specified Telegram chat, including the log file.
# Settings:
#   dbname - MySQL database name
#   dbuser - MySQL user
#   dbpass - MySQL password
#   dump_path - Path for dump files
#   max_backups - Maximum number of backups to keep
#   log_path - Path for log files
#   max_logs - Maximum number of log files to keep
#   telegram_token - Telegram bot token
#   telegram_chat_id - Telegram chat ID
# Example Cronjob Command: 0 3 * * * /path/to/mysql_backup_telegram.sh

# Database and Path Settings
dbname="your_database_name"
dbuser="your_database_user"
dbpass="your_database_password"
dump_path="/path/to/your/backup_directory"
max_backups=7
log_path="/path/to/your/log_directory"
max_logs=10

# Telegram Settings
telegram_token="your_telegram_bot_token"
telegram_chat_id="your_telegram_chat_id"

# Ensure paths end without a slash
dump_path="${dump_path%/}"
log_path="${log_path%/}"

# Current time for file naming
current_time=$(date "+%Y-%m-%d-%H%M%S")
server_name=$(hostname)

# Filename for the dump and log
dump_file="${dump_path}/${dbname}-${current_time}.sql.gz"
log_file="${log_path}/backup-log-${current_time}.txt"

# Prepare directories
mkdir -p "${dump_path}"
mkdir -p "${log_path}"

# Start logging
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>"${log_file}" 2>&1

# Header with server name
echo "Server: ${server_name}"

# Perform mysqldump
echo "Starting backup for database '${dbname}'..."
mysqldump -u "${dbuser}" -p"${dbpass}" "${dbname}" | gzip > "${dump_file}"
if [ $? -eq 0 ]; then
    echo "Backup successful: ${dump_file}"
    log_status="success"
else
    echo "Backup failed for database '${dbname}'"
    log_status="failure"
fi

# Clean up old backups
echo "Checking for old backups to delete..."
num_backups=$(ls -1 "${dump_path}"/*.sql.gz | wc -l)
if [ "${num_backups}" -gt "${max_backups}" ]; then
    let "files_to_delete=${num_backups}-${max_backups}"
    ls -1t "${dump_path}"/*.sql.gz | tail -n "${files_to_delete}" | while read file; do
        rm -f "${file}"
        echo "Deleted old backup: ${file}"
    done
else
    echo "No old backups to delete."
fi

# Clean up old log files
echo "Checking for old logs to delete..."
num_logs=$(ls -1 "${log_path}"/backup-log-*.txt | wc -l)
if [ "${num_logs}" -gt "${max_logs}" ]; then
    let "logs_to_delete=${num_logs}-${max_logs}"
    ls -1t "${log_path}"/backup-log-*.txt | tail -n "${logs_to_delete}" | while read file; do
        rm -f "${file}"
        echo "Deleted old log: ${file}"
    done
else
    echo "No old logs to delete."
fi

# Rename log file based on status
final_log_file="${log_file%.txt}-${log_status}.txt"
mv "${log_file}" "${final_log_file}"

# Send Telegram Message
send_telegram_message() {
    local message=$1
    curl -s -X POST "https://api.telegram.org/bot${telegram_token}/sendMessage" -d chat_id="${telegram_chat_id}" -d text="${message}" -d parse_mode="Markdown"
}

send_telegram_document() {
    local filepath=$1
    curl -s -F chat_id="${telegram_chat_id}" -F document=@"${filepath}" "https://api.telegram.org/bot${telegram_token}/sendDocument"
}

if [ "${log_status}" == "success" ]; then
    send_telegram_message "Backup of ${dbname} on ${server_name} was successful."
else
    send_telegram_message "Backup of ${dbname} on ${server_name} failed."
fi

# Sending log file to Telegram
send_telegram_document "${final_log_file}"

echo "Script completed."
