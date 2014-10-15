require 'formula'

class Ppl10 < Formula
  homepage 'http://bugseng.com/products/ppl/'
  url 'http://bugseng.com/products/ppl/download/ftp/releases/1.0/ppl-1.0.tar.gz'
  sha1 '5f543206cc9de17d48ff797e977547b61b40ab2c'

  depends_on 'homebrew/dupes/m4' => :build if MacOS.version < :leopard
  depends_on 'gmp4'

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-ppl_lpsol",
                          "--disable-ppl_lcdd",
                          "--disable-ppl_pips",
                          "--with-gmp=#{Formula["gmp4"].opt_prefix}"
    system "make install"
  end
end
