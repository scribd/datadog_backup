# [3.0.0-alpha.1](https://github.com/scribd/datadog_backup/compare/v2.0.2...v3.0.0-alpha.1) (2022-08-24)


* feat!: release 3.0 ([d09d9e6](https://github.com/scribd/datadog_backup/commit/d09d9e6c845edb35c49cbb19ec6b35878304a078))


### BREAKING CHANGES

* DATADOG_API_KEY and DATADOG_APP_KEY are no longer the environment variables used to authenticate to Datadog. Instead, set the environment variables DD_API_KEY and DD_APP_KEY.
* ruby 2.6 is no longer supported. Please upgrade to ruby 2.7 or higher.
* The options `--ssh` and `--ssshh` are no longer supported. Instead, please use `--quiet` to supress logging. `--debug` remains supported.
* The environment variable `DATADOG_HOST` is no longer supported. Instead, please use `DD_SITE_URL`.

refactor: The legacy [dogapi-rb ](https://github.com/DataDog/dogapi-rb) gem is replaced with [faraday](https://lostisland.github.io/faraday/).  The [official client library](https://github.com/DataDog/datadog-api-client-ruby) was considered, but was not adopted as I had a hard time grok-ing it.

## [2.0.2](https://github.com/scribd/datadog_backup/compare/v2.0.1...v2.0.2) (2022-08-11)


### Bug Fixes

* Deprecate Ruby 2.6 and Drop support for Ruby 2.5 ([#132](https://github.com/scribd/datadog_backup/issues/132)) ([432cb2c](https://github.com/scribd/datadog_backup/commit/432cb2c0d8b12d89aef81cf35597aa90f77407eb))

## [2.0.1](https://github.com/scribd/datadog_backup/compare/v2.0.0...v2.0.1) (2022-08-11)


### Bug Fixes

* include version.rb in release commit ([#130](https://github.com/scribd/datadog_backup/issues/130)) ([f8df6cc](https://github.com/scribd/datadog_backup/commit/f8df6cc48ac9a3521c3c98dfa2c325f96801d001))

# [2.0.0](https://github.com/scribd/datadog_backup/compare/v1.1.4...v2.0.0) (2022-08-09)


### Bug Fixes

* **deps:** bundle update 20220809 ([#129](https://github.com/scribd/datadog_backup/issues/129)) ([9050752](https://github.com/scribd/datadog_backup/commit/9050752070cfb66cdc9320f51e082d3ddee226c5))


* chore!: drop support for ruby 2.5 and 2.6 (EOL) ([29332c3](https://github.com/scribd/datadog_backup/commit/29332c39f6bb829191e840bc24309651a0ff7f16))


### BREAKING CHANGES

* ruby 2.5 and 2.6 are no longer supported

## [1.1.4](https://github.com/scribd/datadog_backup/compare/v1.1.3...v1.1.4) (2022-06-25)


### Bug Fixes

* **deps:** update diffy requirement from = 3.4.0 to = 3.4.2 ([d241631](https://github.com/scribd/datadog_backup/commit/d2416319c6285d5b499b8c00d7c430be8f05091d))

## [1.1.3](https://github.com/scribd/datadog_backup/compare/v1.1.2...v1.1.3) (2022-03-23)


### Bug Fixes

* **deps:** update concurrent-ruby requirement from = 1.1.9 to = 1.1.10 ([e2eebe6](https://github.com/scribd/datadog_backup/commit/e2eebe6a418b5cd7a8e53e48587f40f4c0b8c90f))

## [1.1.2](https://github.com/scribd/datadog_backup/compare/v1.1.1...v1.1.2) (2022-02-01)


### Bug Fixes

* pin semantic release plugins ([5e92303](https://github.com/scribd/datadog_backup/commit/5e9230362f0b112de190fb1458fc9a3f32423c63))

## [1.1.1](https://github.com/scribd/datadog_backup/compare/v1.1.0...v1.1.1) (2021-10-26)


### Bug Fixes

* **deps:** update amazing_print requirement from = 1.3.0 to = 1.4.0 ([b7e0ca6](https://github.com/scribd/datadog_backup/commit/b7e0ca61f0fb5acbeb541d3b173aa526a0edcf3d))

# [1.1.0](https://github.com/scribd/datadog_backup/compare/v1.0.5...v1.1.0) (2021-07-14)


### Features

* Add support for ruby 2.5 and 3.0 ([#89](https://github.com/scribd/datadog_backup/issues/89)) ([a181dbc](https://github.com/scribd/datadog_backup/commit/a181dbcfd55220e2fd7ce92d384738f71c50baa8))

## [1.0.5](https://github.com/scribd/datadog_backup/compare/v1.0.4...v1.0.5) (2021-07-12)


### Bug Fixes

* Add documentation for DATADOG_HOST usage ([69acc25](https://github.com/scribd/datadog_backup/commit/69acc2574d17310ee090486ec46cb06ab0f450db))

## [1.0.4](https://github.com/scribd/datadog_backup/compare/v1.0.3...v1.0.4) (2021-07-08)


### Bug Fixes

* remove max queue size limit ([b5ee79c](https://github.com/scribd/datadog_backup/commit/b5ee79cc587ef95cebf89bbd8efe9d829af63c8a))

## [1.0.3](https://github.com/scribd/datadog_backup/compare/v1.0.2...v1.0.3) (2021-06-10)


### Bug Fixes

* **deps:** update concurrent-ruby requirement from = 1.1.8 to = 1.1.9 ([31ccccb](https://github.com/scribd/datadog_backup/commit/31ccccbc890792670946923f51e5b883f4cf3e87))

## [1.0.2](https://github.com/scribd/datadog_backup/compare/v1.0.1...v1.0.2) (2021-05-06)


### Bug Fixes

* **deps:** bump rexml from 3.2.4 to 3.2.5 ([15efa8c](https://github.com/scribd/datadog_backup/commit/15efa8c58953d450311fc8e5f125bf7e12401af4))

## [1.0.1](https://github.com/scribd/datadog_backup/compare/v1.0.0...v1.0.1) (2021-03-26)


### Bug Fixes

* dependabot syntax for github ([4214001](https://github.com/scribd/datadog_backup/commit/42140015976ec2d0f4d2fce6e4c3214bb590c967))

# [1.0.0](https://github.com/scribd/datadog_backup/compare/v0.11.0...v1.0.0) (2021-03-02)


### Bug Fixes

* handle gets with no result ([8d016a1](https://github.com/scribd/datadog_backup/commit/8d016a1858b44d374a0dff121c71340bf18062e0))


### Features

* If resource doesn't exist in Datadog, the resource is recreated. ([18ba241](https://github.com/scribd/datadog_backup/commit/18ba24183e136f9d899351bbb0999aba2c22308f))


### BREAKING CHANGES

* `datadog-backup` used to exit with an error if a resource
wasn't found in Datadog.

# [0.11.0](https://github.com/scribd/datadog_backup/compare/v0.10.3...v0.11.0) (2021-01-12)


### Features

* Add force-restore flag to allow running in automation ([#46](https://github.com/scribd/datadog_backup/issues/46)) ([e067386](https://github.com/scribd/datadog_backup/commit/e0673862b6f6d86297e1352faaee872f2c4884c8))

## [0.10.3](https://github.com/scribd/datadog_backup/compare/v0.10.2...v0.10.3) (2020-12-11)


### Performance Improvements

* coerce patch release ([bc86649](https://github.com/scribd/datadog_backup/commit/bc86649b874cd5be1da2f6bc0d1b1ecd0728676c))

## [0.10.2](https://github.com/scribd/datadog_backup/compare/v0.10.1...v0.10.2) (2020-11-03)


### Bug Fixes

* virtual environment updates ruby 2.7.1 -> 2.7.2  ([f950dd6](https://github.com/scribd/datadog_backup/commit/f950dd67ce989bb12de5f2dbf69c6449b91f2542))

## [0.10.1](https://github.com/scribd/datadog_backup/compare/v0.10.0...v0.10.1) (2020-09-08)


### Bug Fixes

* update dependencies ([939ddc7](https://github.com/scribd/datadog_backup/commit/939ddc766eaccc2428eae6486979b919f3bd1c1e))

# [0.10.0](https://github.com/scribd/datadog_backup/compare/v0.9.0...v0.10.0) (2020-08-14)


### Features

* select log levels ([0272d27](https://github.com/scribd/datadog_backup/commit/0272d27530188b36c2b56da6dc075e7507635ecd))

# [0.9.0](https://github.com/scribd/datadog_backup/compare/v0.8.0...v0.9.0) (2020-08-11)


### Features

* public release of datadog_backup ([50d3582](https://github.com/scribd/datadog_backup/commit/50d358284fa3f2c561b1025a3b4f5ce4b4433116))

# [0.8.0](https://github.com/scribd/datadog_backup/compare/v0.7.0...v0.8.0) (2020-08-07)


### Features

* sort keys and ignore banlist for consistency ([ca683a6](https://github.com/scribd/datadog_backup/commit/ca683a63d58eeefee98b5909f830baa0e0bfa426))

# [0.7.0](https://github.com/scribd/datadog_backup/compare/v0.6.0...v0.7.0) (2020-08-07)


### Features

* Purge before backup, so that deletions can be detected. ([bdcb2b0](https://github.com/scribd/datadog_backup/commit/bdcb2b08a2e2e908f8b85359d0a43c392c5253ab))

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
