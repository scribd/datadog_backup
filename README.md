# Datadog Backup

![Rspec and Release](https://github.com/scribd/datadog_backup/workflows/Rspec%20and%20Release/badge.svg)

Use `datadog_backup` to backup your datadog account.
Currently supports

  - dashboards
  - monitors

Additional features may be built out over time.

## Installation

```
gem install datadog_backup
```
or

```
gem build datadog_backup.gemspec
gem install datadog_backup-*.gem
```

## Usage

```
DATADOG_API_KEY=example123 DATADOG_APP_KEY=example123 datadog_backup <backup|diffs|restore> [--backup-dir /path/to/backups] [--debug] [--monitors-only] [--dashboards-only] [--diff-format color|html|html_simple] [--no-color] [--json]
```

```
gem install datadog_backup
export DATADOG_API_KEY=abc123
export DATADOG_APP_KEY=abc123

# Perform backup to optional/path/to/backupdir using YAML encoding
datadog_backup backup --backup-dir optional/path/to/backupdir

# Make some changes

# Just review the changes since last backup
datadog_backup diffs --backup-dir optional/path/to/backupdir

# Review and apply local changes to datadog

datadog_backup restore --backup-dir optional/path/to/backupdir
```

### Usage in a Github repo

See [example/](https://github.com/scribd/datadog_backup/tree/master/example) for an example implementation as a repo that backs up your Datadog dashboards hourly.

# Development

Releases are cut using [semantic-release](https://github.com/semantic-release/semantic-release).

Please write commit messages following [Angular commit guidelines](https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#-git-commit-guidelines)
