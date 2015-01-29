require 'formula'

class Autoconf213 < Formula
  homepage 'https://www.gnu.org/software/autoconf/'
  url 'http://ftpmirror.gnu.org/autoconf/autoconf-2.13.tar.gz'
  mirror 'https://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz'
  sha1 'e4826c8bd85325067818f19b2b2ad2b625da66fc'

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--program-suffix=213",
                          "--prefix=#{prefix}",
                          "--infodir=#{info}",
                          "--datadir=#{share}/autoconf213"
    system "make install"
  end
end
