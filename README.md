# MySQL Backup Telegram

## Description

MySQL Backup Telegram is a Bash script designed for system administrators and developers who need an automated solution to back up their MySQL databases. This script compresses the backup, manages backup and log retention, and notifies the user of the backup's success or failure through Telegram. It's a perfect tool for those who require regular database backups and immediate notification about their status.

## Features

- **Automated MySQL Database Backup**: Automates the backup process and compresses the backup files.
- **Backup and Log Retention**: Allows configuration of how many backup and log files to keep.
- **Telegram Notifications**: Sends notifications via Telegram with the status of each backup attempt.
- **Detailed Logging**: Generates log files detailing the script's actions and outcomes for each run.
- **Cron Job Scheduling**: Easily schedule with cron for hands-free operation.

## Installation

To install MySQL Backup Telegram on an Ubuntu Linux server:

1. **Install `curl`** (skip if already installed):

```bash
sudo apt update && sudo apt install curl -y
```

2. **Download the script**:

```bash
curl -o mysql_backup_telegram.sh https://raw.githubusercontent.com/amotlagh/mysql-backup-telegram/main/mysql_backup_telegram.sh
```

3. **Make the script executable**:

```bash
chmod +x mysql_backup_telegram.sh
```

## Configuration

Before using the script, configure the following parameters inside the `mysql_backup_telegram.sh` file:

- `dbname`: Your MySQL database name.
- `dbuser`: Your MySQL database user.
- `dbpass`: Your MySQL database password.
- `dump_path`: Path to store the backup files.
- `max_backups`: Maximum number of backup files to retain.
- `telegram_token`: Your Telegram bot token.
- `telegram_chat_id`: Your Telegram chat ID.

Use a text editor to edit the script and adjust these settings as needed.

## Running the Script

Execute the script manually by running:

```bash
./mysql_backup_telegram.sh
```

## Automating with Cron

Schedule the script to run automatically with cron. For example, to run it daily at 3:00 AM:

1. Open your crontab file:

```bash
crontab -e
```

2. Add the following line:

```bash
0 3 * * * /path/to/mysql_backup_telegram.sh
```

Ensure to replace `/path/to/` with the actual full path where `mysql_backup_telegram.sh` is located.

## License

This project is licensed under the GNU Public License v3 (GPL-3). 

## Contributions

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests through the [GitHub repository](https://github.com/drhdev/mysql-backup-telegram).

