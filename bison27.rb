require 'formula'

class Bison27 < Formula
  homepage 'https://www.gnu.org/software/bison/'
  url 'http://ftpmirror.gnu.org/bison/bison-2.7.1.tar.gz'
  mirror 'https://ftp.gnu.org/gnu/bison/bison-2.7.1.tar.gz'
  sha1 '676af12f51a95390d9255ada83efa8fbb271be3a'

  bottle do
    root_url "https://downloads.sf.net/project/machomebrew/Bottles/versions"
    sha1 "793cc45598afd5930f0cf524047a9eb46818d26e" => :yosemite
    sha1 "f08f6e998e990512a5e1b35c24656468f0e711f5" => :mavericks
    sha1 "844228c46f2da50052e2f5b67e70988efab431c2" => :mountain_lion
  end

  keg_only :provided_by_osx, 'Some formulae require a newer version of bison.'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end
end
