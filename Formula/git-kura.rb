class GitKura < Formula
  desc "Conflict-aware keyed worktree coordinator for Git"
  homepage "https://github.com/tooppoo/git-kura"
  version "0.1.2"
  license "Apache-2.0"

  depends_on :macos

  on_macos do
    on_arm do
      url "https://github.com/tooppoo/git-kura/releases/download/v#{version}/git-kura_v#{version}_Darwin_arm64.tar.gz"
      sha256 "<sha256-for-git-kura_v#{version}_Darwin_arm64.tar.gz>"
    end

    on_intel do
      url "https://github.com/tooppoo/git-kura/releases/download/v#{version}/git-kura_v#{version}_Darwin_x86_64.tar.gz"
      sha256 "<sha256-for-git-kura_v#{version}_Darwin_x86_64.tar.gz>"
    end
  end

  def install
    bin.install "git-kura"

    pkgshare.install "README.md" if File.exist?("README.md")
    pkgshare.install "LICENSE" if File.exist?("LICENSE")
    pkgshare.install "third_party_licenses" if Dir.exist?("third_party_licenses")
  end

  test do
    output = shell_output("#{bin}/git-kura --version")
    assert_match version.to_s, output
  end
end
