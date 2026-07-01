#!/usr/bin/env ruby
# frozen_string_literal: true

GIT_KURA_REPO_URL = "https://github.com/tooppoo/git-kura"
FORMULA_PATH = "Formula/git-kura.rb"

ASSET_DEFINITIONS = [
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
].freeze

def abort_with(message)
  warn "error: #{message}"
  exit 1
end

def usage
  warn "usage: ruby scripts/update-git-kura-formula.rb <version> <checksums.txt>"
  warn "example: ruby scripts/update-git-kura-formula.rb 0.1.3 checksums.txt"
end

def normalize_version(raw_version)
  raw_version.delete_prefix("v")
end

def validate_version!(version)
  return if version.match?(/\A\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?\z/)

  abort_with("invalid version: #{version}")
end

def sha256_for!(checksums, filename)
  line = checksums.lines.find do |candidate|
    candidate
      .strip
      .split(/\s+/)
      .any? { |token| token.delete_prefix("*") == filename }
  end

  abort_with("missing checksum for #{filename}") unless line

  sha = line.strip.split(/\s+/).find { |part| part.match?(/\A[0-9a-f]{64}\z/) }

  abort_with("invalid checksum line for #{filename}: #{line.strip}") unless sha

  sha
end

def formula_filename(filename_template)
  filename_template.sub("%<version>s", '#{version}')
end

def formula_url(filename_template)
  filename = formula_filename(filename_template)
  "#{GIT_KURA_REPO_URL}/releases/download/v\#{version}/#{filename}"
end

def resolved_url(version, filename)
  "#{GIT_KURA_REPO_URL}/releases/download/v#{version}/#{filename}"
end

def build_assets(version, checksums)
  ASSET_DEFINITIONS.map do |definition|
    filename = format(definition.fetch(:filename_template), version: version)

    definition.merge(
      filename: filename,
      resolved_url: resolved_url(version, filename),
      formula_url: formula_url(definition.fetch(:filename_template)),
      sha256: sha256_for!(checksums, filename)
    )
  end
end

def asset_for!(assets, os:, arch:)
  asset = assets.find do |candidate|
    candidate.fetch(:os) == os && candidate.fetch(:arch) == arch
  end

  abort_with("missing asset definition for #{os}/#{arch}") unless asset

  asset
end

def render_formula(version, assets)
  macos_arm = asset_for!(assets, os: :macos, arch: :arm)
  macos_intel = asset_for!(assets, os: :macos, arch: :intel)
  linux_arm = asset_for!(assets, os: :linux, arch: :arm)
  linux_intel = asset_for!(assets, os: :linux, arch: :intel)

  <<~RUBY
    class GitKura < Formula
      desc "Conflict-aware keyed worktree coordinator for Git"
      homepage "#{GIT_KURA_REPO_URL}"
      version "#{version}"
      license "Apache-2.0"

      on_macos do
        on_arm do
          url "#{macos_arm.fetch(:formula_url)}"
          sha256 "#{macos_arm.fetch(:sha256)}"
        end

        on_intel do
          url "#{macos_intel.fetch(:formula_url)}"
          sha256 "#{macos_intel.fetch(:sha256)}"
        end
      end

      on_linux do
        on_arm do
          url "#{linux_arm.fetch(:formula_url)}"
          sha256 "#{linux_arm.fetch(:sha256)}"
        end

        on_intel do
          url "#{linux_intel.fetch(:formula_url)}"
          sha256 "#{linux_intel.fetch(:sha256)}"
        end
      end

      def install
        bin.install "git-kura"

        pkgshare.install "README.md" if File.exist?("README.md")
        pkgshare.install "LICENSE" if File.exist?("LICENSE")
        pkgshare.install "third_party_licenses" if Dir.exist?("third_party_licenses")
      end

      test do
        output = shell_output("\#{bin}/git-kura --version")
        assert_match version.to_s, output
      end
    end
  RUBY
end

def validate_assets!(assets)
  keys = assets.map { |asset| asset.fetch(:key) }

  ASSET_DEFINITIONS.each do |definition|
    key = definition.fetch(:key)
    abort_with("missing materialized asset: #{key}") unless keys.include?(key)
  end

  assets.each do |asset|
    abort_with("missing filename for #{asset.fetch(:key)}") if asset.fetch(:filename).empty?
    abort_with("missing formula URL for #{asset.fetch(:key)}") if asset.fetch(:formula_url).empty?
    abort_with("missing resolved URL for #{asset.fetch(:key)}") if asset.fetch(:resolved_url).empty?
    abort_with("invalid sha256 for #{asset.fetch(:key)}") unless asset.fetch(:sha256).match?(/\A[0-9a-f]{64}\z/)
  end
end

def validate_formula!(formula, version, assets)
  abort_with("formula does not contain expected version") unless formula.include?(%(version "#{version}"))

  assets.each do |asset|
    unless formula.include?(asset.fetch(:formula_url))
      abort_with("formula does not contain URL for #{asset.fetch(:key)}")
    end

    unless formula.include?(asset.fetch(:sha256))
      abort_with("formula does not contain sha256 for #{asset.fetch(:key)}")
    end
  end
end

if ARGV.length != 2
  usage
  exit 1
end

raw_version = ARGV.fetch(0)
checksums_path = ARGV.fetch(1)

version = normalize_version(raw_version)
validate_version!(version)

abort_with("checksums file does not exist: #{checksums_path}") unless File.file?(checksums_path)

checksums = File.read(checksums_path)

assets = build_assets(version, checksums)
validate_assets!(assets)

formula = render_formula(version, assets)
validate_formula!(formula, version, assets)

File.write(FORMULA_PATH, formula)

puts "updated #{FORMULA_PATH} to git-kura v#{version}"
puts
puts "assets:"
assets.each do |asset|
  puts "- #{asset.fetch(:key)}"
  puts "  filename: #{asset.fetch(:filename)}"
  puts "  url: #{asset.fetch(:resolved_url)}"
  puts "  sha256: #{asset.fetch(:sha256)}"
end
