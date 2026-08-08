class GitKura < Formula
  desc "Conflict-aware keyed worktree coordinator for Git"
  homepage "https://github.com/tooppoo/git-kura"
  version "0.2.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/tooppoo/git-kura/releases/download/v#{version}/git-kura_v#{version}_Darwin_arm64.tar.gz"
      sha256 "ae17084ecf756e3511b3ef5aed76d1510737102eaf9f9f0a7f46fd8a9161eeb7"
    end

    on_intel do
      url "https://github.com/tooppoo/git-kura/releases/download/v#{version}/git-kura_v#{version}_Darwin_x86_64.tar.gz"
      sha256 "c784f126adb6d88da565a6d2d3635842b5eb133ac41335dc75fa5999099951be"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tooppoo/git-kura/releases/download/v#{version}/git-kura_v#{version}_Linux_arm64.tar.gz"
      sha256 "9d7872e968938facb264a15443886ea34c994bbe6953164c2a1afdee66c00eed"
    end

    on_intel do
      url "https://github.com/tooppoo/git-kura/releases/download/v#{version}/git-kura_v#{version}_Linux_x86_64.tar.gz"
      sha256 "2c4f64b5c5712a1e797ec85aca4399df86e3269da8c30b23e9b5a5375c830772"
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
