# frozen_string_literal: true

# Renders a tap formula for a package distributed as prebuilt release tarballs.
#
# Every package in this tap follows the same shape: a GitHub release publishes
# one tarball per (os, arch) plus a checksums.txt, and the formula pins each
# tarball by sha256. The only things that differ per package are the asset
# names and the release tag format, so scripts/<formula>/version-update.rb
# declares just those and delegates the rest here.
class FormulaUpdater
  VERSION_PATTERN = /\A\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?\z/
  SHA256_PATTERN = /\A[0-9a-f]{64}\z/

  # Placeholder used by the caller-supplied templates.
  VERSION_PLACEHOLDER = "%<version>s"
  # Emitted verbatim into the formula so Homebrew interpolates `version` itself.
  FORMULA_VERSION_REF = '#{version}'

  TARGETS = [
    { os: :macos, arch: :arm },
    { os: :macos, arch: :intel },
    { os: :linux, arch: :arm },
    { os: :linux, arch: :intel }
  ].freeze

  # name          - formula name, e.g. "git-kura" (drives the file name, the
  #                 formula class name and the installed binary name)
  # desc          - Homebrew `desc` line
  # repo_url      - GitHub repository URL
  # license       - SPDX identifier
  # tag_template  - release tag, e.g. "v%<version>s" or "%<version>s"
  # assets        - one entry per TARGETS combination, each with :key, :os,
  #                 :arch and :filename_template
  def initialize(name:, desc:, repo_url:, license:, tag_template:, assets:)
    @name = name
    @desc = desc
    @repo_url = repo_url
    @license = license
    @tag_template = tag_template
    @assets = assets
  end

  def run(argv)
    if argv.length != 2
      usage
      exit 1
    end

    version = normalize_version(argv.fetch(0))
    checksums_path = argv.fetch(1)

    validate_version!(version)
    abort_with("checksums file does not exist: #{checksums_path}") unless File.file?(checksums_path)

    assets = build_assets(version, File.read(checksums_path))
    validate_assets!(assets)

    formula = render_formula(version, assets)
    validate_formula!(formula, version, assets)

    File.write(formula_path, formula)

    report(version, assets)
  end

  def formula_path
    "Formula/#{@name}.rb"
  end

  # "git-kura" -> "GitKura", matching Homebrew's own file-to-class rule.
  def formula_class
    @name.split(/[-_]/).map(&:capitalize).join
  end

  private

  def abort_with(message)
    warn "error: #{message}"
    exit 1
  end

  def usage
    warn "usage: ruby #{$PROGRAM_NAME} <version> <checksums.txt>"
    warn "example: ruby #{$PROGRAM_NAME} 1.2.3 checksums.txt"
  end

  def normalize_version(raw_version)
    raw_version.delete_prefix("v")
  end

  def validate_version!(version)
    return if version.match?(VERSION_PATTERN)

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

    sha = line.strip.split(/\s+/).find { |part| part.match?(SHA256_PATTERN) }

    abort_with("invalid checksum line for #{filename}: #{line.strip}") unless sha

    sha
  end

  # Turns "git-kura_v%<version>s_Darwin_arm64.tar.gz" into the literal
  # "git-kura_v#{version}_Darwin_arm64.tar.gz" that the formula carries.
  def to_formula_template(template)
    template.gsub(VERSION_PLACEHOLDER, FORMULA_VERSION_REF)
  end

  def download_url(tag, filename)
    "#{@repo_url}/releases/download/#{tag}/#{filename}"
  end

  def formula_url(filename_template)
    download_url(to_formula_template(@tag_template), to_formula_template(filename_template))
  end

  def resolved_url(version, filename)
    download_url(format(@tag_template, version: version), filename)
  end

  def build_assets(version, checksums)
    @assets.map do |definition|
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
      class #{formula_class} < Formula
        desc "#{@desc}"
        homepage "#{@repo_url}"
        version "#{version}"
        license "#{@license}"

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
          bin.install "#{@name}"

          pkgshare.install "README.md" if File.exist?("README.md")
          pkgshare.install "LICENSE" if File.exist?("LICENSE")
          pkgshare.install "third_party_licenses" if Dir.exist?("third_party_licenses")
        end

        test do
          output = shell_output("\#{bin}/#{@name} --version")
          assert_match version.to_s, output
        end
      end
    RUBY
  end

  def validate_assets!(assets)
    keys = assets.map { |asset| asset.fetch(:key) }

    @assets.each do |definition|
      key = definition.fetch(:key)
      abort_with("missing materialized asset: #{key}") unless keys.include?(key)
    end

    TARGETS.each do |target|
      asset_for!(assets, **target)
    end

    assets.each do |asset|
      abort_with("missing filename for #{asset.fetch(:key)}") if asset.fetch(:filename).empty?
      abort_with("missing formula URL for #{asset.fetch(:key)}") if asset.fetch(:formula_url).empty?
      abort_with("missing resolved URL for #{asset.fetch(:key)}") if asset.fetch(:resolved_url).empty?
      abort_with("invalid sha256 for #{asset.fetch(:key)}") unless asset.fetch(:sha256).match?(SHA256_PATTERN)
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

  def report(version, assets)
    puts "updated #{formula_path} to #{@name} v#{version}"
    puts
    puts "assets:"
    assets.each do |asset|
      puts "- #{asset.fetch(:key)}"
      puts "  filename: #{asset.fetch(:filename)}"
      puts "  url: #{asset.fetch(:resolved_url)}"
      puts "  sha256: #{asset.fetch(:sha256)}"
    end
  end
end
