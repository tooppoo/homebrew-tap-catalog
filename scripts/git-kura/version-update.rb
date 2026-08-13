#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/formula_updater"

FormulaUpdater.new(
  name: "git-kura",
  desc: "Conflict-aware keyed worktree coordinator for Git",
  repo_url: "https://github.com/tooppoo/git-kura",
  license: "Apache-2.0",
  tag_template: "v%<version>s",
  assets: [
    {
      key: :darwin_arm64,
      os: :macos,
      arch: :arm,
      filename_template: "git-kura_v%<version>s_Darwin_arm64.tar.gz"
    },
    {
      key: :darwin_x86_64,
      os: :macos,
      arch: :intel,
      filename_template: "git-kura_v%<version>s_Darwin_x86_64.tar.gz"
    },
    {
      key: :linux_arm64,
      os: :linux,
      arch: :arm,
      filename_template: "git-kura_v%<version>s_Linux_arm64.tar.gz"
    },
    {
      key: :linux_x86_64,
      os: :linux,
      arch: :intel,
      filename_template: "git-kura_v%<version>s_Linux_x86_64.tar.gz"
    }
  ]
).run(ARGV)
