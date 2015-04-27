class Lua53 < Formula
  homepage "http://www.lua.org/"
  url "http://www.lua.org/ftp/lua-5.3.0.tar.gz"
  mirror "https://raw.githubusercontent.com/DomT4/LibreMirror/master/Lua/lua-5.3.0.tar.gz"
  sha256 "ae4a5eb2d660515eb191bfe3e061f2b8ffe94dce73d32cfd0de090ddcc0ddb01"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    revision 1
    sha256 "545b910d9214772d38aff4bda9bc9b75ce24d4b92a6ee1b2b321b63740187964" => :yosemite
    sha256 "5af1b8f06ff335e3344d5a133eb3bcd4fd795857c8dfd4ac889a6ac8b40e1a83" => :mavericks
    sha256 "dd857f57b6f44f50b74988a71485ae8e0d98caf1ec72b44ab2d6a650d4451732" => :mountain_lion
  end

  fails_with :llvm do
    build 2326
    cause "Lua itself compiles with LLVM, but may fail when other software tries to link."
  end

  option :universal
  option "with-completion", "Enables advanced readline support"
  option "with-default-names", "Don't version-suffix the Lua installation. Conflicts with Homebrew/Lua"
  option "without-luarocks", "Don't build with Luarocks support embedded"

  # Be sure to build a dylib, or else runtime modules will pull in another static copy of liblua = crashy
  # See: https://github.com/Homebrew/homebrew/pull/5043
  patch :DATA

  # completion provided by advanced readline power patch
  # See http://lua-users.org/wiki/LuaPowerPatches
  if build.with? "completion"
    patch do
      url "http://luajit.org/patches/lua-5.2.0-advanced_readline.patch"
      sha256 "33d32d11fce4f85b88ce8f9bd54e6a6cbea376dfee3dbf8cdda3640e056bc29d"
    end
  end

  resource "luarocks" do
    url "https://github.com/keplerproject/luarocks/archive/v2.2.1.tar.gz"
    sha256 "30e5bd99f82f5e3ea174572c1831f9ff83dfe37727f9fcfc89168b4572193571"
  end

  def install
    ENV.universal_binary if build.universal?

    # Use our CC/CFLAGS to compile.
    inreplace "src/Makefile" do |s|
      s.remove_make_var! "CC"
      s.change_make_var! "CFLAGS", "#{ENV.cflags} -DLUA_COMPAT_ALL $(SYSCFLAGS) $(MYCFLAGS)"
      s.change_make_var! "MYLDFLAGS", ENV.ldflags
    end

    # Fix path in the config header
    inreplace "src/luaconf.h", "/usr/local", HOMEBREW_PREFIX

    # We ship our own pkg-config file as Lua no longer provide them upstream.
    system "make", "macosx", "INSTALL_TOP=#{prefix}", "INSTALL_MAN=#{man1}", "INSTALL_INC=#{include}/lua-5.3"
    system "make", "install", "INSTALL_TOP=#{prefix}", "INSTALL_MAN=#{man1}", "INSTALL_INC=#{include}/lua-5.3"
    (lib+"pkgconfig/lua.pc").write pc_file

    # Allows side-by-side-by-side-by-side Lua installations
    if build.without? "default-names"
      mv "#{bin}/lua", "#{bin}/lua-5.3"
      mv "#{bin}/luac", "#{bin}/luac-5.3"
      mv "#{man1}/lua.1", "#{man1}/lua-5.3.1"
      mv "#{man1}/luac.1", "#{man1}/luac-5.3.1"
      mv "#{lib}/pkgconfig/lua.pc", "#{lib}/pkgconfig/lua5.3.pc"

      ln_s "#{lib}/pkgconfig/lua5.3.pc", "#{lib}/pkgconfig/lua-5.3.pc"
      ln_s "#{include}/lua-5.3", "#{include}/lua5.3"
      ln_s "#{bin}/lua-5.3", "#{bin}/lua5.3"
      ln_s "#{bin}/luac-5.3", "#{bin}/luac5.3"

      # Patches the pkg-config file to find the correct lib names
      inreplace lib/"pkgconfig/lua5.3.pc", "Libs: -L${libdir} -llua -lm", "Libs: -L${libdir} -llua5.3 -lm"
    end

    # This resource must be handled after the main install, since there's a lua dep.
    # Keeping it in install rather than postinstall means we can bottle.
    if build.with? "luarocks"
      resource("luarocks").stage do
        ENV.prepend_path "PATH", bin
        lua_prefix = prefix

        system "./configure", "--prefix=#{libexec}", "--rocks-tree=#{HOMEBREW_PREFIX}",
                              "--sysconfdir=#{etc}/luarocks53", "--with-lua=#{lua_prefix}",
                              "--lua-version=5.3", "--versioned-rocks-dir", "--force-config=#{etc}/luarocks53"
        system "make", "build"
        system "make", "install"

        (share+"lua/5.3/luarocks").install_symlink Dir["#{libexec}/share/lua/5.3/luarocks/*"]
        bin.install_symlink libexec/"bin/luarocks-5.3"
        bin.install_symlink libexec/"bin/luarocks-admin-5.3"

        # This block ensures luarock exec scripts don't break across updates.
        inreplace libexec/"share/lua/5.3/luarocks/site_config.lua" do |s|
          s.gsub! "#{HOMEBREW_CELLAR}/lua53/#{pkg_version}/libexec", "#{Formula["lua53"].opt_libexec}"
          s.gsub! "#{HOMEBREW_CELLAR}/lua53/#{pkg_version}/include", "#{HOMEBREW_PREFIX}/include"
          s.gsub! "#{HOMEBREW_CELLAR}/lua53/#{pkg_version}/lib", "#{HOMEBREW_PREFIX}/lib"
          s.gsub! "#{HOMEBREW_CELLAR}/lua53/#{pkg_version}/bin", "#{HOMEBREW_PREFIX}/bin"
        end
      end
    end
  end

  def pc_file; <<-EOS.undent
    V= 5.3
    R= 5.3.0
    prefix=#{HOMEBREW_PREFIX}
    INSTALL_BIN= ${prefix}/bin
    INSTALL_INC= ${prefix}/include/lua-5.3
    INSTALL_LIB= ${prefix}/lib
    INSTALL_MAN= ${prefix}/share/man/man1
    INSTALL_LMOD= ${prefix}/share/lua/${V}
    INSTALL_CMOD= ${prefix}/lib/lua/${V}
    exec_prefix=${prefix}
    libdir=${exec_prefix}/lib
    includedir=${prefix}/include/lua-5.3

    Name: Lua
    Description: An Extensible Extension Language
    Version: 5.3.0
    Requires:
    Libs: -L${libdir} -llua -lm
    Cflags: -I${includedir}
    EOS
  end

  test do
    system "#{bin}/lua-5.3", "-e", "print ('Ducks are cool')"
  end
end

__END__
diff --git a/Makefile b/Makefile
index 7fa91c8..a825198 100644
--- a/Makefile
+++ b/Makefile
@@ -41,7 +41,7 @@ PLATS= aix bsd c89 freebsd generic linux macosx mingw posix solaris
 # What to install.
 TO_BIN= lua luac
 TO_INC= lua.h luaconf.h lualib.h lauxlib.h lua.hpp
-TO_LIB= liblua.a
+TO_LIB= liblua.5.3.0.dylib
 TO_MAN= lua.1 luac.1

 # Lua version and release.
@@ -63,6 +63,7 @@ install: dummy
	cd src && $(INSTALL_DATA) $(TO_INC) $(INSTALL_INC)
	cd src && $(INSTALL_DATA) $(TO_LIB) $(INSTALL_LIB)
	cd doc && $(INSTALL_DATA) $(TO_MAN) $(INSTALL_MAN)
+	ln -s -f liblua.5.3.0.dylib $(INSTALL_LIB)/liblua.5.3.dylib

 uninstall:
	cd src && cd $(INSTALL_BIN) && $(RM) $(TO_BIN)
diff --git a/src/Makefile b/src/Makefile
index 2e7a412..d0c4898 100644
--- a/src/Makefile
+++ b/src/Makefile
@@ -28,7 +28,7 @@ MYOBJS=

 PLATS= aix bsd c89 freebsd generic linux macosx mingw posix solaris

-LUA_A=	liblua.a
+LUA_A=	liblua.5.3.0.dylib
 CORE_O=	lapi.o lcode.o lctype.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o \
	lmem.o lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o \
	ltm.o lundump.o lvm.o lzio.o
@@ -56,11 +56,12 @@ o:	$(ALL_O)
 a:	$(ALL_A)

 $(LUA_A): $(BASE_O)
-	$(AR) $@ $(BASE_O)
-	$(RANLIB) $@
+	$(CC) -dynamiclib -install_name HOMEBREW_PREFIX/lib/liblua.5.3.dylib \
+		-compatibility_version 5.3 -current_version 5.3.0 \
+		-o liblua.5.3.0.dylib $^

 $(LUA_T): $(LUA_O) $(LUA_A)
-	$(CC) -o $@ $(LDFLAGS) $(LUA_O) $(LUA_A) $(LIBS)
+	$(CC) -fno-common $(MYLDFLAGS) -o $@ $(LUA_O) $(LUA_A) -L. -llua.5.3.0 $(LIBS)

 $(LUAC_T): $(LUAC_O) $(LUA_A)
	$(CC) -o $@ $(LDFLAGS) $(LUAC_O) $(LUA_A) $(LIBS)
@@ -110,7 +111,7 @@ linux:
	$(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_LINUX" SYSLIBS="-Wl,-E -ldl -lreadline"

 macosx:
-	$(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_MACOSX" SYSLIBS="-lreadline" CC=cc
+	$(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_MACOSX -fno-common" SYSLIBS="-lreadline" CC=cc

 mingw:
	$(MAKE) "LUA_A=lua53.dll" "LUA_T=lua.exe" \
