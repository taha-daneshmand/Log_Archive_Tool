import os
import sys
import tarfile
import datetime
import argparse
import logging
import shutil
import smtplib
from email.message import EmailMessage

def setup_logging(log_file):
    logging.basicConfig(filename=log_file, level=logging.INFO,
                        format='%(asctime)s - %(levelname)s - %(message)s', 
                        datefmt='%Y-%m-%d %H:%M:%S')

def create_archive(log_directory, archive_dir, retention_days):
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    archive_name = f"logs_archive_{timestamp}.tar.gz"
    archive_path = os.path.join(archive_dir, archive_name)
    
    with tarfile.open(archive_path, "w:gz") as tar:
        tar.add(log_directory, arcname=os.path.basename(log_directory))
    
    logging.info(f"Archive created: {archive_path}")
    
    remove_old_archives(archive_dir, retention_days)
    
    return archive_path

def remove_old_archives(archive_dir, retention_days):
    current_time = datetime.datetime.now()
    for filename in os.listdir(archive_dir):
        file_path = os.path.join(archive_dir, filename)
        file_modified = datetime.datetime.fromtimestamp(os.path.getmtime(file_path))
        if (current_time - file_modified).days > retention_days:
            os.remove(file_path)
            logging.info(f"Removed old archive: {file_path}")

def clean_logs(log_directory, days_to_keep):
    current_time = datetime.datetime.now()
    for root, _, files in os.walk(log_directory):
        for file in files:
            file_path = os.path.join(root, file)
            file_modified = datetime.datetime.fromtimestamp(os.path.getmtime(file_path))
            if (current_time - file_modified).days > days_to_keep:
                os.remove(file_path)
                logging.info(f"Removed old log file: {file_path}")

def send_email(sender, password, recipient, subject, body):
    msg = EmailMessage()
    msg.set_content(body)
    msg['Subject'] = subject
    msg['From'] = sender
    msg['To'] = recipient

    try:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp:
            smtp.login(sender, password)
            smtp.send_message(msg)
        logging.info("Email notification sent successfully")
    except Exception as e:
        logging.error(f"Failed to send email: {str(e)}")

def main():
    parser = argparse.ArgumentParser(description="Archive and manage log files.")
    parser.add_argument("log_directory", help="Directory containing logs to archive")
    parser.add_argument("-a", "--archive-dir", default="log_archives", 
                        help="Directory to store archives (default: log_archives)")
    parser.add_argument("-r", "--retention", type=int, default=30, 
                        help="Number of days to retain archives (default: 30)")
    parser.add_argument("-c", "--clean", type=int, 
                        help="Clean log files older than specified days")
    parser.add_argument("-l", "--log-file", default="log_archiver.log", 
                        help="Log file for the archiver (default: log_archiver.log)")
    parser.add_argument("-e", "--email", nargs=4, 
                        metavar=('SENDER', 'PASSWORD', 'RECIPIENT', 'SUBJECT'),
                        help="Send email notification after archiving")
    args = parser.parse_args()

    if not os.path.isdir(args.log_directory):
        print(f"Error: {args.log_directory} is not a valid directory")
        sys.exit(1)

    setup_logging(args.log_file)
    os.makedirs(args.archive_dir, exist_ok=True)

    archive_path = create_archive(args.log_directory, args.archive_dir, args.retention)
    print(f"Logs archived successfully: {archive_path}")

    if args.clean:
        clean_logs(args.log_directory, args.clean)
        print(f"Cleaned log files older than {args.clean} days")

    if args.email:
        sender, password, recipient, subject = args.email
        body = f"Log archive created: {archive_path}"
        send_email(sender, password, recipient, subject, body)
        print("Email notification sent")

if __name__ == "__main__":
    main()
