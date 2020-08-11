module.exports = {
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
          "CHANGELOG.md"
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
