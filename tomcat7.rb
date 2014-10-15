require 'formula'

class Tomcat7 < Formula
  homepage "http://tomcat.apache.org/"
  url "http://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-7/v7.0.56/bin/apache-tomcat-7.0.56.tar.gz"
  sha1 "21c16dfed30b4a15c129e4448e63834103c88272"

  option "with-fulldocs", "Install full documentation locally"

  resource "fulldocs" do
    url "http://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-7/v7.0.56/bin/apache-tomcat-7.0.56-fulldocs.tar.gz"
    version "7.0.56"
    sha1 "a32018b4c6870de95935acac41991c2ba0539c79"
  end

  # Keep log folders
  skip_clean 'libexec'

  def install
    # Remove Windows scripts
    rm_rf Dir['bin/*.bat']

    # Install files
    prefix.install %w{ NOTICE LICENSE RELEASE-NOTES RUNNING.txt }
    libexec.install Dir['*']
    bin.install_symlink "#{libexec}/bin/catalina.sh" => "catalina"

    (share/'fulldocs').install resource('fulldocs') if build.with? 'fulldocs'
  end
end
