# Datadog Backup

Use `datadog_backup` to backup your datadog account.
Currently supports

  - dashboards
  - monitors

Additional features may be built out over time.

## Installation

```
$ gem install datadog_backup
```

## Usage

```
$ DATADOG_API_KEY=example123 DATADOG_APP_KEY=example123 datadog_sync backup --backup-dir=./
```
