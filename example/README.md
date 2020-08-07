# Example-datadog-backups
Dashboards and monitors are backed up here on an hourly basis. 

Github Actions uses the [datadog_backup gem](https://github.com/scribd/datadog_backup) in order to sync the latest copy of what's in Datadog. 

## Performing edits to Datadog monitors and dashboards
1. Do it in the Datadog UI
2. At the top of the hour, the changes will be recorded here.
3. If you're in a rush, click on "Run workflow" from the Github Actions workflow menus

## Performing bulk edits to Datadog monitors and dashboards
1. Clone this repo
2. `bundle install`
3. `bundle exec datadog_backup backup` to download the latest changes in Datadog.
4. Make your changes locally.
5. `bundle exec datadog_backup restore` to apply your changes.
6. Review each change and apply it (r), or download the latest copy from Datadog (d).
