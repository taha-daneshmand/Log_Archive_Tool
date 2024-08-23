#!/bin/bash

set -e

ARCHIVE_DIR="log_archives"
RETENTION_DAYS=30
LOG_FILE="log_archiver.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

create_archive() {
    local log_dir="$1"
    local archive_name="logs_archive_$(date '+%Y%m%d_%H%M%S').tar.gz"
    local archive_path="$ARCHIVE_DIR/$archive_name"

    mkdir -p "$ARCHIVE_DIR"
    tar -czf "$archive_path" -C "$(dirname "$log_dir")" "$(basename "$log_dir")"
    log_message "Archive created: $archive_path"
    echo "$archive_path"
}

remove_old_archives() {
    find "$ARCHIVE_DIR" -name "logs_archive_*.tar.gz" -mtime +$RETENTION_DAYS -delete
    log_message "Removed archives older than $RETENTION_DAYS days"
}

clean_logs() {
    local log_dir="$1"
    local days_to_keep="$2"
    find "$log_dir" -type f -mtime +$days_to_keep -delete
    log_message "Cleaned log files older than $days_to_keep days in $log_dir"
}

send_email() {
    local sender="$1"
    local recipient="$2"
    local subject="$3"
    local body="$4"

    echo "$body" | mail -s "$subject" -r "$sender" "$recipient"
    log_message "Email notification sent to $recipient"
}

usage() {
    echo "Usage: $0 -d <log_directory> [-a <archive_dir>] [-r <retention_days>] [-c <clean_days>] [-l <log_file>] [-e <sender> <recipient> <subject>]"
    echo "  -d: Directory containing logs to archive (required)"
    echo "  -a: Directory to store archives (default: $ARCHIVE_DIR)"
    echo "  -r: Number of days to retain archives (default: $RETENTION_DAYS)"
    echo "  -c: Clean log files older than specified days"
    echo "  -l: Log file for the archiver (default: $LOG_FILE)"
    echo "  -e: Send email notification after archiving (requires sender, recipient, and subject)"
    exit 1
}

while getopts ":d:a:r:c:l:e:" opt; do
    case $opt in
        d) LOG_DIR="$OPTARG" ;;
        a) ARCHIVE_DIR="$OPTARG" ;;
        r) RETENTION_DAYS="$OPTARG" ;;
        c) CLEAN_DAYS="$OPTARG" ;;
        l) LOG_FILE="$OPTARG" ;;
        e) 
            EMAIL_SENDER="$OPTARG"
            EMAIL_RECIPIENT="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
            EMAIL_SUBJECT="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
            ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
        :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
    esac
done

if [ -z "$LOG_DIR" ]; then
    echo "Error: Log directory is required."
    usage
fi

if [ ! -d "$LOG_DIR" ]; then
    echo "Error: $LOG_DIR is not a valid directory"
    exit 1
fi

ARCHIVE_PATH=$(create_archive "$LOG_DIR")
echo "Logs archived successfully: $ARCHIVE_PATH"

remove_old_archives

if [ -n "$CLEAN_DAYS" ]; then
    clean_logs "$LOG_DIR" "$CLEAN_DAYS"
    echo "Cleaned log files older than $CLEAN_DAYS days"
fi

if [ -n "$EMAIL_SENDER" ] && [ -n "$EMAIL_RECIPIENT" ] && [ -n "$EMAIL_SUBJECT" ]; then
    send_email "$EMAIL_SENDER" "$EMAIL_RECIPIENT" "$EMAIL_SUBJECT" "Log archive created: $ARCHIVE_PATH"
    echo "Email notification sent"
fi
