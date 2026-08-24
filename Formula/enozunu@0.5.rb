class EnozunuAT05 < Formula
  desc "Cross-provider configuration materializer for AI agent tooling"
  homepage "https://github.com/tooppoo/enozunu"
  version "0.5.0"
  license "Apache-2.0"
  keg_only :versioned_formula

  on_macos do
    on_arm do
      url "https://github.com/tooppoo/enozunu/releases/download/#{version}/enozunu_#{version}_Darwin_arm64.tar.gz"
      sha256 "89fd3ba5733b79a98c99094a1adbc7a5c2c958849bfc46a3e09541314597b018"
    end

    on_intel do
      url "https://github.com/tooppoo/enozunu/releases/download/#{version}/enozunu_#{version}_Darwin_x86_64.tar.gz"
      sha256 "47bd097eb16e6ea53f12832b051ea70d13bbcd47c7ffab9ddfe2919728584d30"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tooppoo/enozunu/releases/download/#{version}/enozunu_#{version}_Linux_aarch64.tar.gz"
      sha256 "c99b04b9d1c32664f512fa6d9eb46147452fe8bd70620a2faa6d88f4c1558bdf"
    end

    on_intel do
      url "https://github.com/tooppoo/enozunu/releases/download/#{version}/enozunu_#{version}_Linux_x86_64.tar.gz"
      sha256 "f6c6202e6ad569bb2d13b17882e1ced0396f1c5037cf51324043b8147eaecbc3"
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
