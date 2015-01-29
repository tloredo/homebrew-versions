require 'formula'

class Automake112 < Formula
  homepage 'https://www.gnu.org/software/automake/'
  url 'http://ftpmirror.gnu.org/automake/automake-1.12.6.tar.gz'
  mirror 'https://ftp.gnu.org/gnu/automake/automake-1.12.6.tar.gz'
  sha1 '34bfda1c720e1170358562b1667e533a203878d6'

  depends_on 'autoconf' => :run

  keg_only :provided_until_xcode43

  def install
    system "./configure", "--prefix=#{prefix}", "--program-suffix=112"
    system "make install"

    # Our aclocal must go first. See:
    # https://github.com/mxcl/homebrew/issues/10618
    (share/"aclocal/dirlist").write <<-EOS.undent
      #{HOMEBREW_PREFIX}/share/aclocal
      /usr/share/aclocal
    EOS
  end

  test do
    system "#{bin}/automake112", "--version"
  end
end
