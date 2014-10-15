require "formula"

class Libdvdcss12 < Formula
  homepage "http://www.videolan.org/developers/libdvdcss.html"
  url "http://download.videolan.org/pub/libdvdcss/1.2.13/libdvdcss-1.2.13.tar.bz2"
  sha1 "1a4a5e55c7529da46386c1c333340eee2c325a77"

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make install"
  end
end

