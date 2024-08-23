# Log Archive Tool

![GitHub last commit](https://img.shields.io/github/last-commit/taha-daneshmand/log_archive_tool)
![GitHub issues](https://img.shields.io/github/issues/taha-daneshmand/log_archive_tool)
![GitHub pull requests](https://img.shields.io/github/issues-pr/taha-daneshmand/log_archive_tool)
![GitHub](https://img.shields.io/github/license/taha-daneshmand/log_archive_tool)

A powerful and flexible command-line tool for archiving and managing log files on Unix-based systems. This tool compresses logs, stores them in a designated directory, and provides options for log retention, cleaning, and email notifications.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Options](#options)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

## Features

- Compress and archive log files
- Customizable archive storage location
- Automatic removal of old archives based on retention period
- Option to clean old log files from the original directory
- Email notifications upon successful archiving
- Detailed logging of all operations

## Requirements

- Bash (for bash version)
- Python 3.6+ (for Python version)
- Unix-like operating system (Linux, macOS, etc.)

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/taha-daneshmand/log_archive_tool.git
   ```

2. Navigate to the project directory:
   ```
   cd log_archive_tool
   ```

3. Make the script executable:
   ```
   chmod +x main.sh
   ```

## Usage

### Bash Version

```
./main.sh -d <log_directory> [options]
```

## Options

| Option | Description |
|--------|-------------|
| `-d, --log-directory` | Directory containing logs to archive (required) |
| `-a, --archive-dir` | Directory to store archives (default: log_archives) |
| `-r, --retention` | Number of days to retain archives (default: 30) |
| `-c, --clean` | Clean log files older than specified days |
| `-l, --log-file` | Log file for the archiver (default: log_archiver.log) |
| `-e, --email` | Send email notification after archiving (requires sender, recipient, and subject) |

## Examples

1. Basic usage:
   ```
   ./main.sh -d /var/log
   ```

2. Specify archive directory and retention period:
   ```
   ./main.sh -d /var/log -a /path/to/archives -r 60
   ```

3. Clean old logs and send email notification:
   ```
   ./main.sh -d /var/log -c 7 -e "sender@example.com" "recipient@example.com" "Log Archive Created"
   ```

4. Specify a custom log file:
   ```
   ./main.sh -d /var/log -l /path/to/custom_log_file.log
   ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

This project was inspired by a challenge from [roadmap.sh](https://roadmap.sh/projects/log_archive_tool).
