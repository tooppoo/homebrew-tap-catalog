class Enozunu < Formula
  desc "Cross-provider configuration materializer for AI agent tooling"
  homepage "https://github.com/tooppoo/enozunu"
  version "0.3.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/tooppoo/enozunu/releases/download/#{version}/enozunu_#{version}_Darwin_arm64.tar.gz"
      sha256 "09fbd4e626a24c9428e370aa57e1a7626cfe660724bcabe97c6a68cf10d05241"
    end

    on_intel do
      url "https://github.com/tooppoo/enozunu/releases/download/#{version}/enozunu_#{version}_Darwin_x86_64.tar.gz"
      sha256 "938a9380abfd8a7134c859b9283ea7f14c6614f157e4fd909d49d760085e6d08"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tooppoo/enozunu/releases/download/#{version}/enozunu_#{version}_Linux_aarch64.tar.gz"
      sha256 "0f0ac0a17f23b58595ec2c790905700ffa6245840d677c5442af6be032c2f19a"
    end

    on_intel do
      url "https://github.com/tooppoo/enozunu/releases/download/#{version}/enozunu_#{version}_Linux_x86_64.tar.gz"
      sha256 "16ed2afe803ff1ed846541f960d6b25988c564de6f1ec253e9f92408fe39ac41"
    end
  end

  def install
    bin.install "enozunu"

    pkgshare.install "README.md" if File.exist?("README.md")
    pkgshare.install "LICENSE" if File.exist?("LICENSE")
    pkgshare.install "third_party_licenses" if Dir.exist?("third_party_licenses")
  end

  test do
    output = shell_output("#{bin}/enozunu --version")
    assert_match version.to_s, output
  end
end
