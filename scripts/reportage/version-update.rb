#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/formula_updater"

# reportage release tags carry no "v" prefix, and its Linux arm asset is named
# "aarch64" rather than "arm64".
FormulaUpdater.new(
  name: "reportage",
  desc: "Explicit, runtime-agnostic, coverage-aware E2E scenario runner",
  repo_url: "https://github.com/tooppoo/reportage",
  license: "Apache-2.0",
  tag_template: "%<version>s",
  assets: [
    {
      key: :darwin_arm64,
      os: :macos,
      arch: :arm,
      filename_template: "reportage_%<version>s_Darwin_arm64.tar.gz"
    },
    {
      key: :darwin_x86_64,
      os: :macos,
      arch: :intel,
      filename_template: "reportage_%<version>s_Darwin_x86_64.tar.gz"
    },
    {
      key: :linux_aarch64,
      os: :linux,
      arch: :arm,
      filename_template: "reportage_%<version>s_Linux_aarch64.tar.gz"
    },
    {
      key: :linux_x86_64,
      os: :linux,
      arch: :intel,
      filename_template: "reportage_%<version>s_Linux_x86_64.tar.gz"
    }
  ]
).run(ARGV)
