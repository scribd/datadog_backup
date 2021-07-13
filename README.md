# Datadog Backup

![Rspec and Release](https://github.com/scribd/datadog_backup/workflows/Rspec%20and%20Release/badge.svg)
[![Gem Version](https://badge.fury.io/rb/datadog_backup.svg)](https://badge.fury.io/rb/datadog_backup)

Use `datadog_backup` to backup your datadog account.
Currently supports

  - dashboards
  - monitors

Additional features may be built out over time.

## Installation

```
gem install datadog_backup
```

## Usage

![demo](images/demo.gif)

```
DATADOG_API_KEY=example123 DATADOG_APP_KEY=example123 datadog_backup <backup|diffs|restore> [--backup-dir /path/to/backups] [--debug] [--monitors-only] [--dashboards-only] [--diff-format color|html|html_simple] [--no-color] [--json]
```

```
gem install datadog_backup
export DATADOG_API_KEY=abc123
export DATADOG_APP_KEY=abc123

# Perform backup to `./backup/` using YAML encoding
datadog_backup backup

# Make some changes

# Just review the changes since last backup
datadog_backup diffs

# Review the changes since last backup and apply local changes to datadog

datadog_backup restore
```
## Parameters

Supply the following parameters in order to customize datadog_backup:

parameter            | description                                                                                                                   | default
---------------------|-------------------------------------------------------------------------------------------------------------------------------|--------------------------
--debug              | log debug and above                                                                                                           | info
--shh                | log warnings and above                                                                                                        | info
--shhh               | log errors and above                                                                                                          | info
--backup-dir PATH    | path to the directory to backup to or restore from                                                                            | `./backup/`
--monitors-only      | only backup monitors                                                                                                          | backup monitors and dashboards
--dashboards-only    | only backup dashboards                                                                                                        | backup monitors and dashboards
--json               | format backups as JSON instead of YAML. Does not impact `diffs` nor `restore`, but do not mix formats in the same backup-dir. | YAML
--no-color           | removes colored output from diff format
--diff-format FORMAT | one of `color`, `html_simple`, `html`                                                                                         | `color`
--force-restore      | Force restore to Datadog. Do not ask to validate. Non-interactive.
--h, --help          | help

## Environment variables

The following environment variables can be set in order to further customize datadog_backup:

environment variable | description                                                                      | default
---------------------|--------------------------------------------------------------------------------|--------------------------
DATADOG_HOST         | Describe the API endpoint to connect to (https://api.datadoghq.eu for example)   | https://api.datadoghq.com
http_proxy           | Instruct Dogapi to connect via a differnt proxy address                          | none
https_proxy          | Same as `http_proxy`                                                             | none
dd_proxy_https       | Same as `http_proxy`                                                             | none


### Usage in a Github repo

See [example/](https://github.com/scribd/datadog_backup/tree/master/example) for an example implementation as a repo that backs up your Datadog dashboards hourly.

# Development

Releases are cut using [semantic-release](https://github.com/semantic-release/semantic-release).

Please write commit messages following [Angular commit guidelines](https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#-git-commit-guidelines)
