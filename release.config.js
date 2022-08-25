module.exports = {
  "release": {
    "branches": [
      '+([0-9])?(.{+([0-9]),x}).x',
      'main',
      {name: 'alpha', prerelease: true}
    ]
  },
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    [
      "@semantic-release/changelog",
      {
        "changelogFile": "CHANGELOG.md"
      }
    ],
    [
      "semantic-release-rubygem",
      {
        "gemFileDir": "."
      }
    ],
    [
      "@semantic-release/git",
      {
        "assets": [
          "CHANGELOG.md",
          "lib/datadog_backup/version.rb"
        ],
        "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
      }
    ],
    [
      "@semantic-release/github",
      {
        "assets": [
          {
            "path": "datadog_backup.zip",
            "name": "datadog_backup.${nextRelease.version}.zip",
            "label": "Full zip distribution"
          },
          {
            "path": "datadog_backup-*.gem",
            "label": "Gem distribution"
          }
        ]
      }
    ],
  ]
};
