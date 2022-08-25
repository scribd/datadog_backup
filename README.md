# Datadog Backup

![Rspec and Release](https://github.com/scribd/datadog_backup/workflows/Rspec%20and%20Release/badge.svg)
[![Gem Version](https://badge.fury.io/rb/datadog_backup.svg)](https://badge.fury.io/rb/datadog_backup)

Use `datadog_backup` to backup your datadog account.
Currently supports

  - dashboards
  - monitors

Additional features may be built out over time.

# v3 Migration

## Breaking Changes
v3 is a backwards incompatible change.

- [] DATADOG_API_KEY and DATADOG_APP_KEY are no longer the environment variables used to authenticate to Datadog. Instead, set the environment variables DD_API_KEY and DD_APP_KEY.
- [ ] ruby 2.6 is no longer supported. Please upgrade to ruby 2.7 or higher.
- [ ] The options `--ssh` and `--ssshh` are no longer supported. Instead, please use `--quiet` to supress logging. `--debug` remains supported.
- [ ] The environment variable `DATADOG_HOST` is no longer supported. Instead, please use `DD_SITE_URL`.

## Misc
- [ ] The legacy [dogapi-rb ](https://github.com/DataDog/dogapi-rb) gem is replaced with [faraday](https://lostisland.github.io/faraday/).  The [official client library](https://github.com/DataDog/datadog-api-client-ruby) was considered, but was not adopted as I had a hard time grok-ing it.


## Installation

```
gem install datadog_backup
```

## Usage

![demo](images/demo.gif)

```
DD_API_KEY=example123 DD_APP_KEY=example123 datadog_backup <backup|diffs|restore> [--backup-dir /path/to/backups] [--debug] [--monitors-only] [--dashboards-only] [--diff-format color|html|html_simple] [--no-color] [--json]
```

```
gem install datadog_backup
export DD_API_KEY=abc123
export DD_APP_KEY=abc123

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
--quiet              | only show errors and above                                                                                                    | info
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
DD_SITE_URL          | Describe the API endpoint to connect to (https://api.datadoghq.eu for example)   | https://api.datadoghq.com
DD_API_KEY           | The API key for the Datadog account                                              | none
DD_API_KEY           | The Application key for the Datadog account                                      | none


### Usage in a Github repo

See [example/](https://github.com/scribd/datadog_backup/tree/main/example) for an example implementation as a repo that backs up your Datadog dashboards hourly.

# Development

Releases are cut using [semantic-release](https://github.com/semantic-release/semantic-release).

Please write commit messages following [Angular commit guidelines](https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#-git-commit-guidelines)
