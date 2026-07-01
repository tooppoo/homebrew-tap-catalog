class GitKura < Formula
  desc "Conflict-aware keyed worktree coordinator for Git"
  homepage "https://github.com/tooppoo/git-kura"
  version "0.1.2"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/tooppoo/git-kura/releases/download/v#{version}/git-kura_v#{version}_Darwin_arm64.tar.gz"
      sha256 "df5f726ca8fd8d42c594543ef60edb3ae2965fb0bd741b35dfa01c3bf61d974a"
    end

    on_intel do
      url "https://github.com/tooppoo/git-kura/releases/download/v#{version}/git-kura_v#{version}_Darwin_x86_64.tar.gz"
      sha256 "21acd2c3f729831f5ea18fdca1b9f725beacc94df896ebfb9b7af81ec8e6fa7f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tooppoo/git-kura/releases/download/v#{version}/git-kura_v#{version}_Linux_arm64.tar.gz"
      sha256 "0aaa1b54769631cd90eb53551a1b487450b72973b68cfa28debf4369cb3da212"
    end
  
    on_intel do
      url "https://github.com/tooppoo/git-kura/releases/download/v#{version}/git-kura_v#{version}_Linux_x86_64.tar.gz"
      sha256 "aa227eba50bb31d269bd9f49b5f58eea0e43b42e71a2bfe6de00a31abf8c0906"
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
