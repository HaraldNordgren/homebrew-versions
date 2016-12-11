require 'formula'

class BashCompletion < Formula
  version "2"
  homepage 'http://bash-completion.alioth.debian.org/'
  url 'http://bash-completion.alioth.debian.org/files/bash-completion-2.0.tar.bz2'
  sha256 'e5a490a4301dfb228361bdca2ffca597958e47dd6056005ef9393a5852af5804'

  conflicts_with 'bash-completion'

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

      Any completion scripts in #{Formula.factory("bash-completion").compdir}
      will continue to be sourced as well.
    EOS
  end
end
