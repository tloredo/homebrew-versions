class Postgresql9 < Formula
  homepage "http://www.postgresql.org/"
  url "http://ftp.postgresql.org/pub/source/v9.0.17/postgresql-9.0.17.tar.bz2"
  sha256 "d2f6d09cf941e7cbab6ee399f14080dbe822af58fda9fd132efb05c2b7d160ad"
  revision 1

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    revision 1
    sha1 "d17aaa78b2b34d3b1a29709d3ed992eeaf0defe0" => :yosemite
    sha1 "b4d646d80df53ca080f16ccdc9611f597e4baffb" => :mavericks
    sha1 "90796fc3ad9450da3a452da8204cfbf2b2ceba42" => :mountain_lion
  end

  depends_on "openssl"
  depends_on "readline"
  depends_on "libxml2" if MacOS.version == :leopard
  depends_on "ossp-uuid" => :recommended

  option "without-python", "Build without Python support"
  option "without-perl", "Build without Perl support"
  option "without-tcl", "Build without Tcl support"
  option "with-dtrace", "Build with DTrace support"

  deprecated_option "no-python" => "without-python"
  deprecated_option "no-perl" => "without-perl"
  deprecated_option "no-tcl" => "without-tcl"
  deprecated_option "enable-dtrace" => "with-dtrace"

  # Fix uuid-ossp build issues: http://archives.postgresql.org/pgsql-general/2012-07/msg00654.php
  patch :DATA

  def install
    ENV.libxml2 if MacOS.version >= :snow_leopard

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --datadir=#{share}/#{name}
      --docdir=#{doc}
      --enable-thread-safety
      --with-bonjour
      --with-gssapi
      --with-krb5
      --with-openssl
      --with-libxml
      --with-libxslt
    ]

    args << "--with-ossp-uuid" if build.with? "ossp-uuid"
    args << "--with-python" if build.with? "python"
    args << "--with-perl" if build.with? "perl"

    # The CLT is required to build tcl support on 10.7 and 10.8 because tclConfig.sh is not part of the SDK
    if build.with?("tcl") && (MacOS.version >= :mavericks || MacOS::CLT.installed?)
      args << "--with-tcl"

      if File.exist?("#{MacOS.sdk_path}/usr/lib/tclConfig.sh")
        args << "--with-tclconfig=#{MacOS.sdk_path}/usr/lib"
      end
    end

    args << "--enable-dtrace" if build.with? "dtrace"

    if build.with? "ossp-uuid"
      ENV.append "CFLAGS", `uuid-config --cflags`.strip
      ENV.append "LDFLAGS", `uuid-config --ldflags`.strip
      ENV.append "LIBS", `uuid-config --libs`.strip
    end

    if MacOS.prefer_64_bit? and build.with? "python"
      args << "ARCHFLAGS='-arch x86_64'"
      check_python_arch
    end

    system "./configure", *args
    system "make", "install-world"
  end

  def check_python_arch
    # On 64-bit systems, we need to look for a 32-bit Framework Python.
    # The configure script prefers this Python version, and if it doesn't
    # have 64-bit support then linking will fail.
    framework_python = Pathname.new "/Library/Frameworks/Python.framework/Versions/Current/Python"
    return unless framework_python.exist?
    unless (archs_for_command framework_python).include? :x86_64
      opoo "Detected a framework Python that does not have 64-bit support in:"
      puts <<-EOS.undent
          #{framework_python}

        The configure script seems to prefer this version of Python over any others,
        so you may experience linker problems as described in:
          http://osdir.com/ml/pgsql-general/2009-09/msg00160.html

        To fix this issue, you may need to either delete the version of Python
        shown above, or move it out of the way before brewing PostgreSQL.

        Note that a framework Python in /Library/Frameworks/Python.framework is
        the "MacPython" verison, and not the system-provided version which is in:
          /System/Library/Frameworks/Python.framework
      EOS
    end
  end

  def caveats
    s = <<-EOS.undent
      If builds of PostgreSQL 9 are failing and you have version 8.x installed,
      you may need to remove the previous version first. See:
        https://github.com/mxcl/homebrew/issues/issue/2510

      To build plpython against a specific Python, set PYTHON prior to brewing:
        PYTHON=/usr/local/bin/python brew install postgresql
      See:
        http://www.postgresql.org/docs/9.0/static/install-procedure.html

      If this is your first install, create a database with:
        initdb #{var}/postgres9

      Some machines may require provisioning of shared memory:
        http://www.postgresql.org/docs/current/static/kernel-resources.html#SYSVIPC
    EOS

    if MacOS.prefer_64_bit?
      s << "\n" << <<-EOS.undent
        When installing the postgres gem, including ARCHFLAGS is recommended:
          ARCHFLAGS="-arch x86_64" gem install pg

        To install gems without sudo, see the Homebrew wiki.
      EOS
    end
    s
  end

  plist_options :manual => "pg_ctl -D #{HOMEBREW_PREFIX}/var/postgres -l #{HOMEBREW_PREFIX}/var/postgres/server.log start"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_prefix}/bin/postgres</string>
        <string>-D</string>
        <string>#{var}/postgres</string>
        <string>-r</string>
        <string>#{var}/postgres/server.log</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/initdb", testpath
  end
end

__END__
diff --git a/contrib/uuid-ossp/uuid-ossp.c b/contrib/uuid-ossp/uuid-ossp.c
index d4fc62b..62b28ca 100644
--- a/contrib/uuid-ossp/uuid-ossp.c
+++ b/contrib/uuid-ossp/uuid-ossp.c
@@ -9,6 +9,7 @@
  *-------------------------------------------------------------------------
  */

+#define _XOPEN_SOURCE
 #include "postgres.h"
 #include "fmgr.h"
 #include "utils/builtins.h"
