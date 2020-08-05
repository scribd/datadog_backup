# [0.6.0](https://github.com/scribd/datadog_backup/compare/v0.5.0...v0.6.0) (2020-08-05)


### Bug Fixes

* enable datadog_backup executable to run restore ([5094813](https://github.com/scribd/datadog_backup/commit/50948132b154c30956b87b5ec1e9070d34a48a02))
* order is not guaranteed ([d65b9a8](https://github.com/scribd/datadog_backup/commit/d65b9a872c268bcd91384f9f0215b88bdc5e9544))
* restore actually restores ([0e80999](https://github.com/scribd/datadog_backup/commit/0e80999b9d90cecb7c04c639d593987d89c35616))
* rspec properly handles SystemExit ([cf26bfb](https://github.com/scribd/datadog_backup/commit/cf26bfb7dd28d4b14c2126487848cab4d9af2bf9))


### Features

* add restore flow ([8175a03](https://github.com/scribd/datadog_backup/commit/8175a033b34b268f4a9850d1629dfdb21e86d2fa))
* Change defaults to YAML(backups) and color(diffs) ([d9ed708](https://github.com/scribd/datadog_backup/commit/d9ed7084f4cb8a5357ce0ab2927df770f0b841ed))
* ignore key ordering changes ([47e6e9f](https://github.com/scribd/datadog_backup/commit/47e6e9f7f5ac7824a57f8cee45bfe68867bba760))
* use Diffy diffs rather than HashDiff:x ([e5529b8](https://github.com/scribd/datadog_backup/commit/e5529b8f8501c2534f26bd0d541afa20c076b5c0))

# [0.5.0](https://github.com/scribd/datadog_backup/compare/v0.4.0...v0.5.0) (2020-07-30)


### Features

* Handle Ctrl-c by closing down the worker pool ([96791ba](https://github.com/scribd/datadog_backup/commit/96791ba23997114c356a097eb7a096ef2f7bd31c))
* use thread pool to globally limit thread count ([915f5c2](https://github.com/scribd/datadog_backup/commit/915f5c27be2fdf1f3bde40c34d8999ee1248de43))

# [0.4.0](https://github.com/scribd/datadog_backup/compare/v0.3.0...v0.4.0) (2020-07-27)


### Bug Fixes

* use maintained 'amazing_print' gem, rather than suffer a bajillion error messages ([a988416](https://github.com/scribd/datadog_backup/commit/a988416de11fd83ddd2d5bcf5b78bed59de65694))


### Features

* `diffs` provides a diff between what's on disk and in datadog ([8599b47](https://github.com/scribd/datadog_backup/commit/8599b47cd8761292247331982d9332f6b4da07b4))
* add `diffs` function ([3f5cd41](https://github.com/scribd/datadog_backup/commit/3f5cd41ae6bae99abb44a1495ea76c527ddc0428))

# [0.3.0](https://github.com/scribd/datadog_backup/compare/v0.2.0...v0.3.0) (2020-07-24)


### Features

* add yaml option ([5645e71](https://github.com/scribd/datadog_backup/commit/5645e71826ee474201d54f51ed061ab1d3f9e872))

# [0.2.0](https://github.com/scribd/datadog_backup/compare/v0.1.0...v0.2.0) (2020-07-18)


### Features

* send debug array to DEBUG ([0ef8bd7](https://github.com/scribd/datadog_backup/commit/0ef8bd71beba051e5ba4cddc9142507b505bc945))

# [0.1.0](https://github.com/scribd/datadog_backup/compare/v0.0.3...v0.1.0) (2020-07-17)


### Features

* change default backup directory to 'backup' ([27c8f69](https://github.com/scribd/datadog_backup/commit/27c8f6914147801b10de7e24cfa7e2742010fd89))
