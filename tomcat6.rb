require 'formula'

class Tomcat6 < Formula
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-6/v6.0.44/bin/apache-tomcat-6.0.44.tar.gz"
  sha256 "aab792322e75c6502675120933cbc519cfb59ac8d192f4fa103371a335708224"

  keg_only "Some scripts that are installed conflict with other software."

  option "with-fulldocs", "Install full documentation locally"

  resource "fulldocs" do
    url "https://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-6/v6.0.44/bin/apache-tomcat-6.0.44-fulldocs.tar.gz"
    version "6.0.44"
    sha256 "baddc7066915ac05a0facc5fe1b90f31717021392960e15d87c5a1c8be13b5dd"
  end

  def install
    rm_rf Dir['bin/*.{cmd,bat]}']
    libexec.install Dir['*']
    (libexec+'logs').mkpath
    bin.mkpath
    Dir["#{libexec}/bin/*.sh"].each { |f| ln_s f, bin }
    (share/'fulldocs').install resource('fulldocs') if build.with? 'fulldocs'
  end

  def caveats; <<-EOS.undent
    Some of the support scripts used by Tomcat have very generic names.
    These are likely to conflict with support scripts used by other Java-based
    server software.

    You can link Tomcat into PATH with:

      brew link tomcat6

    or add #{bin} to your PATH instead.
    EOS
  end
end
