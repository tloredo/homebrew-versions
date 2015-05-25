class Tomcat7 < Formula
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-7/v7.0.62/bin/apache-tomcat-7.0.62.tar.gz"
  sha256 "a787ea12e163e78ccebbb9662d7da78e707aef051d15af9ab5be20489adf1f6d"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha256 "9f44bf780148b5f9a46b8a7e23243157c563d1405ad883e52113379e9ac73f96" => :yosemite
    sha256 "51d1d46ea51a1e843f2bc960250ee3bbe3d1e309aa31044d4bcea7f63558a007" => :mavericks
    sha256 "4bb7d4bd8c153963eaaf83c79d6c947bc83b264d7c380389f9696e2740412f05" => :mountain_lion
  end

  option "with-fulldocs", "Install full documentation locally"

  resource "fulldocs" do
    url "https://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-7/v7.0.62/bin/apache-tomcat-7.0.62-fulldocs.tar.gz"
    version "7.0.62"
    sha256 "46aa0412c1d0f041757e1e8dc9a0561507e3586a400165eafe4479e5adb5e86b"
  end

  # Keep log folders
  skip_clean "libexec"

  def install
    # Remove Windows scripts
    rm_rf Dir["bin/*.bat"]

    # Install files
    prefix.install %w{ NOTICE LICENSE RELEASE-NOTES RUNNING.txt }
    libexec.install Dir["*"]
    bin.install_symlink "#{libexec}/bin/catalina.sh" => "catalina"

    (share/"fulldocs").install resource("fulldocs") if build.with? "fulldocs"
  end
end
