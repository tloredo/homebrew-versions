class Tomcat7 < Formula
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-7/v7.0.61/bin/apache-tomcat-7.0.61.tar.gz"
  sha256 "2528ad7434e44ab1198b5692d5f831ac605051129119fd81a00d4c75abe1c0e0"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha256 "80ebcd42d337ab33d7bd0294193838e4d1a5945eafb44e07f254ba3e1229d725" => :yosemite
    sha256 "55c01b38aac5ec11ffcfbc5a8de7eff817afa4f964c4a50210f5a5021a611c06" => :mavericks
    sha256 "2f0d0aaa88b3a730d6c1b936c9251cba2968e15d89a5b1372e129870146969b3" => :mountain_lion
  end

  option "with-fulldocs", "Install full documentation locally"

  resource "fulldocs" do
    url "https://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-7/v7.0.61/bin/apache-tomcat-7.0.61-fulldocs.tar.gz"
    version "7.0.61"
    sha256 "30f0ccc080a46dd7fc2dfaccd3f3b8efdec5d5d42e235637e1de518a77ea86f3"
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
