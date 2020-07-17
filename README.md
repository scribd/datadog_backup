# Datadog Backup

Use `datadog_backup` to backup your datadog account.
Currently supports

  - dashboards
  - monitors

Additional features may be built out over time.

## Installation

```
gem build datadog_backup.gemspec
gem install datadog_backup-*.gem
```

## Usage

```
DATADOG_API_KEY=example123 DATADOG_APP_KEY=example123 datadog_sync backup [--backup-dir /path/to/backups] [--verbose] [--monitors-only] [--dashboards-only]
```

# Development

Releases are cut using [semantic-release](https://github.com/semantic-release/semantic-release).

Please write commit messages following [Angular commit guidelines](https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#-git-commit-guidelines)
