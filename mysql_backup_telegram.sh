#!/bin/bash

# Script Name: MySQL Backup Telegram
# Version: 1.0
# Author: drhdev
# Description: This script performs a backup of a specified MySQL database, compresses the backup,
#              and sends it to a specified Telegram chat.
# Settings:
#   dbname - MySQL database name
#   dbuser - MySQL user
#   dbpass - MySQL password
#   dump_path - Path for dump files
#   telegram_token - Telegram bot token
#   telegram_chat_id - Telegram chat ID
# Example Cronjob Command: 0 3 * * * /path/to/mysql_backup_telegram.sh

# Database and Path Settings
dbname="your_database_name"
dbuser="your_database_user"
dbpass="your_database_password"
dump_path="/path/to/your/backup_directory"

# Telegram Settings
telegram_token="your_telegram_bot_token"
telegram_chat_id="your_telegram_chat_id"

# Ensure paths end without a slash
dump_path="${dump_path%/}"

# Current time for file naming
current_time=$(date "+%Y-%m-%d-%H%M%S")
server_name=$(hostname)

# Filename for the dump
dump_file="${dump_path}/${dbname}-${current_time}.sql.gz"

# Prepare directory
mkdir -p "${dump_path}"

# Perform mysqldump
echo "Starting backup for database '${dbname}'..."
mysqldump -u "${dbuser}" -p"${dbpass}" "${dbname}" | gzip > "${dump_file}"
if [ $? -eq 0 ]; then
    echo "Backup successful: ${dump_file}"
else
    echo "Backup failed for database '${dbname}'"
fi

# Send Telegram Message
send_telegram_message() {
    local message=$1
    curl -s -X POST "https://api.telegram.org/bot${telegram_token}/sendMessage" -d chat_id="${telegram_chat_id}" -d text="${message}" -d parse_mode="Markdown"
}

send_telegram_document() {
    local filepath=$1
    curl -s -F chat_id="${telegram_chat_id}" -F document=@"${filepath}" "https://api.telegram.org/bot${telegram_token}/sendDocument"
}

send_telegram_message "Backup of ${dbname} on ${server_name} was successful."
send_telegram_document "${dump_file}"

echo "Script completed."
