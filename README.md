# Datadog Sync

Use `datadog_sync` to backup your datadog account.
Currently supports

  - dashboards
  - monitors

Additional features may be built out over time.

## Installation

```
$ gem install datadog_sync
```

## Usage

```
$ DATADOG_API_KEY=example123 DATADOG_APP_KEY=example123 datadog_sync backup --output-dir=./
$ DATADOG_API_KEY=example123 DATADOG_APP_KEY=example123 datadog_sync restore --output-dir=./
```
