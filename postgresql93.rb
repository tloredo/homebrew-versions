class Postgresql93 < Formula
  homepage "http://www.postgresql.org/"
  url "http://ftp.postgresql.org/pub/source/v9.3.8/postgresql-9.3.8.tar.bz2"
  sha256 "bc5c3ce755dfc5f6fbc0186a564f97abac3c2914f9a5d5a47f22f4fd354aadfa"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "6cec00a518d229e388f6021f137635b2ce97aa3ddeb0099043ac5ed9752b6767" => :yosemite
    sha256 "4a1ea93af8e8879efcc7f82119df647706be2e7e7c1883d24ba303644428d6e8" => :mavericks
    sha256 "34ed5815e8a27565ebb7272f66d868f09e8a0f6fa86fb4607a8a1a059194406e" => :mountain_lion
  end

  depends_on "openssl"
  depends_on "readline"
  depends_on "libxml2" if MacOS.version <= :leopard # Leopard libxml is too old
  depends_on "ossp-uuid" => :recommended # ossp-uuid is no longer required for uuid support since 9.4beta2
  depends_on :python => :optional

  option "32-bit"
  option "without-perl", "Build without Perl support"
  option "without-tcl", "Build without Tcl support"
  option "with-dtrace", "Build with DTrace support"

  deprecated_option "no-perl" => "without-perl"
  deprecated_option "no-tcl" => "without-tcl"
  deprecated_option "enable-dtrace" => "with-dtrace"

  conflicts_with "postgres-xc",
    :because => "postgresql and postgres-xc install the same binaries."

  fails_with :clang do
    build 211
    cause "Miscompilation resulting in segfault on queries"
  end

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
      --with-ldap
      --with-openssl
      --with-pam
      --with-libxml
      --with-libxslt
    ]

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

    if build.with?("ossp-uuid")
      args << "--with-ossp-uuid"
      ENV.append "CFLAGS", `uuid-config --cflags`.strip
      ENV.append "LDFLAGS", `uuid-config --ldflags`.strip
      ENV.append "LIBS", `uuid-config --libs`.strip
    end

    if build.build_32_bit?
      ENV.append ["CFLAGS", "LDFLAGS"], "-arch #{Hardware::CPU.arch_32_bit}"
    end

    system "./configure", *args
    system "make", "install-world"
  end

  def caveats
    s = <<-EOS.undent
    initdb #{var}/postgres -E utf8    # create a database
    postgres -D #{var}/postgres       # serve that database
    PGDATA=#{var}/postgres postgres   # ...alternatively

    If builds of PostgreSQL 9 are failing and you have version 8.x installed,
    you may need to remove the previous version first. See:
      https://github.com/Homebrew/homebrew/issues/issue/2510

    To migrate existing data from a previous major version (pre-9.3) of PostgreSQL, see:
      http://www.postgresql.org/docs/9.3/static/upgrading.html
    EOS

    if MacOS.prefer_64_bit?
      s << <<-EOS.undent
      \nWhen installing the postgres gem, including ARCHFLAGS is recommended:
        ARCHFLAGS="-arch x86_64" gem install pg

      To install gems without sudo, see the Homebrew documentation:
      https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Gems,-Eggs-and-Perl-Modules.md
      EOS
    end

    s
  end

  plist_options :manual => "postgres -D #{HOMEBREW_PREFIX}/var/postgres"

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
        <string>#{opt_bin}/postgres</string>
        <string>-D</string>
        <string>#{var}/postgres</string>
        <string>-r</string>
        <string>#{var}/postgres/server.log</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/postgres/server.log</string>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/initdb", testpath/"test"
  end
end


__END__
--- a/contrib/uuid-ossp/uuid-ossp.c	2012-07-30 18:34:53.000000000 -0700
+++ b/contrib/uuid-ossp/uuid-ossp.c	2012-07-30 18:35:03.000000000 -0700
@@ -9,6 +9,8 @@
  *-------------------------------------------------------------------------
  */

+#define _XOPEN_SOURCE
+
 #include "postgres.h"
 #include "fmgr.h"
 #include "utils/builtins.h"
