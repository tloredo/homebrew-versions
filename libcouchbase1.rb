require 'formula'

class Libcouchbase1 < Formula
  homepage 'http://couchbase.com/develop/c/current'
  url 'http://packages.couchbase.com/clients/c/libcouchbase-1.0.6.tar.gz'
  sha1 '733479568b851382059b82bdd093b92081f9ac9c'

  conflicts_with 'libcouchbase'

  depends_on 'libevent'
  depends_on 'libvbucket'

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-couchbasemock"
    system "make install"
  end

  test do
    system "#{bin}/cbc-version"
  end
end
