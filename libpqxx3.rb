class Libpqxx3 < Formula
  homepage "http://pqxx.org/development/libpqxx/"
  url "http://pqxx.org/download/software/libpqxx/libpqxx-3.1.1.tar.gz"
  sha1 "b8942164495310894cab39e5882c42f092570fc5"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha1 "4b252768206da1560e33af4baefb689f475556a8" => :yosemite
    sha1 "4b9dbfb332c12c1b8b8b16fff11a66d2b5ad9621" => :mavericks
    sha1 "e968d6871cc9e35c709d15eaa6c8704fe84c6a12" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on :postgresql

  # Patch 1 borrowed from MacPorts. See:
  # https://trac.macports.org/ticket/33671
  #
  # (1) Patched maketemporary to avoid an error message about improper use
  #     of the mktemp command; apparently maketemporary is designed to call
  #     mktemp in various ways, some of which may be improper, as it attempts
  #     to determine how to use it properly; we don't want to see those errors
  #     in the configure phase output.
  # (2) Patched largeobject.hxx per the ticket at the following URL:
  #     http://pqxx.org/development/libpqxx/ticket/252
  patch :DATA

  def install
    ENV.deparallelize

    system "./configure", "--prefix=#{prefix}", "--enable-shared"
    system "make", "install"
  end
end

__END__
diff --git a/tools/maketemporary b/tools/maketemporary
index 242f63b..f9f6661 100755
--- a/tools/maketemporary
+++ b/tools/maketemporary
@@ -5,7 +5,7 @@
 TMPDIR="${TMPDIR:-/tmp}"
 export TMPDIR

-T="`mktemp`"
+T="`mktemp 2>/dev/null`"
 if test -z "$T" ; then
	      T="`mktemp -t pqxx.XXXXXX`"
 fi
diff --git a/include/pqxx/largeobject.hxx b/include/pqxx/largeobject.hxx
index 73d16c0..b2caeed 100644
--- a/include/pqxx/largeobject.hxx
+++ b/include/pqxx/largeobject.hxx
@@ -396,7 +396,7 @@ public:
			openmode mode = PGSTD::ios::in | PGSTD::ios::out,
			size_type BufSize=512) :			//[t48]
     m_BufSize(BufSize),
-    m_Obj(T, O),
+    m_Obj(T, O, mode),
     m_G(0),
     m_P(0)
	{ initialize(mode); }
@@ -406,7 +406,7 @@ public:
			openmode mode = PGSTD::ios::in | PGSTD::ios::out,
			size_type BufSize=512) :			//[t48]
     m_BufSize(BufSize),
-    m_Obj(T, O),
+    m_Obj(T, O, mode),
     m_G(0),
     m_P(0)
	{ initialize(mode); }
