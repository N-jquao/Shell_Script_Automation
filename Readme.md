# Automated Backup Script

A Bash shell script that automates backups of a specified directory, verifies the integrity of the resulting archive, removes old backups, and notifies the system administrator by email when a backup completes.

## Features

- **Automated backups** - compresses a source directory into a timestamped `.tar.gz` archive.
- **Integrity checking** - generates a SHA-256 checksum for each archive so backups can be verified later.
- **Retention policy** - automatically deletes archives older than a configurable number of days.
- **Logging** - records every step (start, success/failure, integrity, cleanup) to a log file.
- **Email notification** - emails the system administrator once a backup run finishes.

## Prerequisites

- A Linux system with Bash.
- `tar` and `sha256sum` (both standard on most distributions).
- A configured Mail Transfer Agent (MTA) so the `mail` command can send email (e.g. `mailutils` or `s-nail`).
- Write permission to the backup, log, and destination directories (the script is typically run as root or via `sudo`).

## Configuration

Edit the variables at the top of the script to match your environment:

| Variable | Description | Example |
|----------|-------------|---------|
| `SOURCE_DIR` | Directory to back up | `/home/linux` |
| `BACKUP_DIR` | Directory where archives are stored | `/backups` |
| `LOG_DIR` | Directory for logs | `/var/log` |
| `RETENTION_DAYS` | Number of days to keep old backups | `7` |
| `BACKUP_LOG` | Path to the log file | `/var/log/backup_script.log` |

Also update the recipient address in the `notify` function (`user@email.com`) to the administrator's email.

## Usage

Make the script executable and run it:

```bash
chmod +x backup_script.sh
sudo ./backup_script.sh
```

### Scheduling with cron

To run the backup automatically (for example, every day at 2:00 AM), add a cron entry:

```bash
sudo crontab -e
```

Then add:

```
0 2 * * * /path/to/backup_script.sh
```

## How It Works

1. **backup** - creates a timestamped archive of `SOURCE_DIR` in `BACKUP_DIR` using `tar -czf`, and logs whether it succeeded or failed.
2. **integrity** - runs `sha256sum` on the new archive and writes the checksum to a `.sha256` file alongside it.
3. **cleanup_old_backups** - uses `find` to remove `.tar.gz` archives older than `RETENTION_DAYS`.
4. **notify** - sends the log contents to the administrator by email to confirm completion.

## Verifying a Backup

To confirm an archive has not been corrupted, use its checksum file:

```bash
sha256sum -c project_backup_<timestamp>.tar.gz.sha256
```

## Logs

All activity is appended to the file defined by `BACKUP_LOG` (default `/var/log/backup_script.log`). Each entry is timestamped, so you can review past runs and troubleshoot failures.

## Recommendations

A couple of optional improvements worth applying:

- Use a compact timestamp format so archive filenames are clean and sortable. Replace `TIMESTAMP=$(date)` with `TIMESTAMP=$(date +%Y%m%d_%H%M%S)` to produce names like `project_backup_20260822_103045.tar.gz` instead of names containing spaces and colons.
- Add `mkdir -p "$BACKUP_DIR"` near the top so the first run does not fail if the backup directory does not yet exist.
