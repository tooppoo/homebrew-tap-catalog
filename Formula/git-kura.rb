class GitKura < Formula
  desc "Conflict-aware keyed worktree coordinator for Git"
  homepage "https://github.com/tooppoo/git-kura"
  version "0.0.6"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/tooppoo/git-kura/releases/download/v#{version}/git-kura_v#{version}_Darwin_arm64.tar.gz"
      sha256 "eec5ae05016d662ece45f0af0f3f273f2710123a2b59d733c00aafbe63df8cdd"
    end

    on_intel do
      url "https://github.com/tooppoo/git-kura/releases/download/v#{version}/git-kura_v#{version}_Darwin_x86_64.tar.gz"
      sha256 "94b8aa98de53232268da2ec5b908eb320c94ba65678ac61adcf5f37b908c44a9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tooppoo/git-kura/releases/download/v#{version}/git-kura_v#{version}_Linux_arm64.tar.gz"
      sha256 "62fddec8252892585ff3659b4e079a1ea5de393a8e05e58738c58f53425b84f3"
    end

    on_intel do
      url "https://github.com/tooppoo/git-kura/releases/download/v#{version}/git-kura_v#{version}_Linux_x86_64.tar.gz"
      sha256 "e6e2dbc0ffe6679f03389deda329c797cc106f49050d5e219960d2b63bf29d3a"
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
