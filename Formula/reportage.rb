class Reportage < Formula
  desc "Explicit, runtime-agnostic, coverage-aware E2E scenario runner"
  homepage "https://github.com/tooppoo/reportage"
  version "0.0.7"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/tooppoo/reportage/releases/download/#{version}/reportage_#{version}_Darwin_arm64.tar.gz"
      sha256 "9762aec87bfb96afc3d0f3dab41f2bda6d0f652aa71fef42ed3a7adb7816fbe2"
    end

    on_intel do
      url "https://github.com/tooppoo/reportage/releases/download/#{version}/reportage_#{version}_Darwin_x86_64.tar.gz"
      sha256 "feaca3a7bb3ca16c58ac6aa7a539bfc41a67be49e730c489855d341a3e6aa280"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tooppoo/reportage/releases/download/#{version}/reportage_#{version}_Linux_aarch64.tar.gz"
      sha256 "b48eb660bc8065e5170165122c37144d3dcd4241ee1104017e30ca06e4434c7b"
    end

    on_intel do
      url "https://github.com/tooppoo/reportage/releases/download/#{version}/reportage_#{version}_Linux_x86_64.tar.gz"
      sha256 "16377427bef529f42d694c934b506601a9e96cb7d4247c0c81f14d81519fe6e0"
    end
  end

  def install
    bin.install "reportage"

    pkgshare.install "README.md" if File.exist?("README.md")
    pkgshare.install "LICENSE" if File.exist?("LICENSE")
    pkgshare.install "third_party_licenses" if Dir.exist?("third_party_licenses")
  end

  test do
    output = shell_output("#{bin}/reportage --version")
    assert_match version.to_s, output
  end
end
