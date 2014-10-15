require 'formula'

class Ppl011 < Formula
  homepage 'http://bugseng.com/products/ppl/'
  # Track gcc infrastructure releases.
  url 'http://bugseng.com/products/ppl/download/ftp/releases/0.11/ppl-0.11.tar.gz'
  mirror 'ftp://gcc.gnu.org/pub/gcc/infrastructure/ppl-0.11.tar.gz'
  sha1 'b3b12de9bcd156ed9254f76259835f40e162afc8'

  keg_only 'Conflicts with ppl in main repository.'

  depends_on 'homebrew/dupes/m4' => :build if MacOS.version < :leopard
  depends_on 'gmp4'

  # https://www.cs.unipr.it/mantis/view.php?id=596
  # See also: https://github.com/Homebrew/homebrew/issues/27431
  #
  # Using a slightly different patch other than the one in upstream bug report
  # to avoid autoreconf.
  patch do
    url "https://gist.githubusercontent.com/manphiz/9507743/raw/45081e12c2f1faf81e8536f365af05173c6dab5c/patch-ppl-flexible-array-clang_v2.patch"
    sha1 "b60eaa2d5c5c0bef1be20ac9bee126e8af1c182e"
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-ppl_lpsol",
                          "--disable-ppl_lcdd",
                          "--disable-ppl_pips",
                          "--with-gmp-prefix=#{Formula["gmp4"].opt_prefix}"
    system "make install"
  end
end
