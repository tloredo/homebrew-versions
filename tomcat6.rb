require 'formula'

class Tomcat6 < Formula
  homepage 'http://tomcat.apache.org/'
  url 'http://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-6/v6.0.43/bin/apache-tomcat-6.0.43.tar.gz'
  sha1 '455d9aabb7fa0372623dce43b403166379c820c6'

  keg_only "Some scripts that are installed conflict with other software."

  option "with-fulldocs", "Install full documentation locally"

  resource 'fulldocs' do
    url 'http://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-6/v6.0.43/bin/apache-tomcat-6.0.43-fulldocs.tar.gz'
    version '6.0.43'
    sha1 '7114d0e774103ab29ad87c8a97c089f8ae1083a8'
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
