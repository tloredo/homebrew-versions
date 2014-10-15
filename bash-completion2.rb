require 'formula'

class BashCompletion2 < Formula
  homepage 'http://bash-completion.alioth.debian.org/'
  url 'http://ftp.de.debian.org/debian/pool/main/b/bash-completion/bash-completion_2.1.orig.tar.bz2'
  sha256 '2b606804a7d5f823380a882e0f7b6c8a37b0e768e72c3d4107c51fbe8a46ae4f'
  revision 2

  conflicts_with 'bash-completion'

  # All three fix issues with GNU extended regexs
  patch do
    url "http://anonscm.debian.org/gitweb/?p=bash-completion/bash-completion.git;a=patch;h=f230cfddbd12b8c777040e33bac1174c0e2898af"
    sha1 "0805407d8221281eed569e102fd8f81292b54e31"
  end

  patch do
    url "http://anonscm.debian.org/gitweb/?p=bash-completion/bash-completion.git;a=patch;h=3ac523f57e8d26e0943dfb2fd22f4a8879741c60"
    sha1 "9fd6805b60b1ee5093e8b8cac2191df640905aa6"
  end

  patch do
    url "http://anonscm.debian.org/gitweb/?p=bash-completion/bash-completion.git;a=patch;h=50ae57927365a16c830899cc1714be73237bdcb2"
    sha1 "e14ac827a59f48eb05e7da60b6fce996be1a34f4"
  end

  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=739835
  # resolves issue with completion of files/directories with spaces in the name.
  patch do
    url "http://anonscm.debian.org/cgit/bash-completion/debian.git/plain/debian/patches/00-fix_quote_readline_by_ref.patch?id=d734ca3bd73ae49b8f452802fb8fb65a440ab07a"
    sha1 "5dc4f7428d968807fc6cce0fe70ba07ca187150b"
  end

  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=739835
  # https://bugs.launchpad.net/ubuntu/+source/bash-completion/+bug/1289597
  patch :DATA

  def compdir
    HOMEBREW_PREFIX/'share/bash-completion/completions'
  end

  def install
    inreplace 'bash_completion', 'readlink -f', 'readlink'

    system "./configure", "--prefix=#{prefix}", "--sysconfdir=#{etc}"
    ENV.deparallelize
    system "make install"

    unless (compdir/'brew').exist?
      compdir.install_symlink HOMEBREW_CONTRIB/'brew_bash_completion.sh' => 'brew'
    end
  end

  def caveats; <<-EOS.undent
    Add the following to your ~/.bash_profile:
      if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
        . $(brew --prefix)/share/bash-completion/bash_completion
      fi

      Homebrew's own bash completion script has been linked into
        #{compdir}
      bash-completion will automatically source it when you invoke `brew`.

      Any completion scripts in #{Formula["bash-completion"].compdir}
      will continue to be sourced as well.
    EOS
  end
end

__END__
diff --git a/bash_completion b/bash_completion
index 6d3ba76..5d9c645 100644
--- a/bash_completion
+++ b/bash_completion
@@ -707,7 +707,7 @@ _init_completion()
         fi
     done
 
-    [[ $cword -eq 0 ]] && return 1
+    [[ $cword -le 0 ]] && return 1
     prev=${words[cword-1]}
 
     [[ ${split-} ]] && _split_longopt && split=true
