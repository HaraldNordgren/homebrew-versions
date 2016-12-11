require 'formula'

<<-COMMENTS

Options
-------
There are a few options for customzing the build.
  --universal: Builds combined 32-/64-bit Intel binaries.
  --framework: Builds a "Framework" version of Python.
  --static:    Builds static instead of shared libraries.

site-packages
-------------
The "site-packages" folder lives in the Cellar, under the "lib" folder
for normal builds, and under the "Frameworks" folder for Framework builds.

A .pth file is added to the Cellar site-packages that adds the corresponding
HOMEBREW_PREFIX folder (/usr/local/lib/python2.6/site-packages by default)
to sys.path. Note that this alternate folder doesn't itself support .pth files.

pip / distribute
----------------
The pip (and distribute) formulae in Homebrew are designed only to work
against a Homebrew-installed Python, though they provide links for
manually installing against a custom Python.

pip and distribute are installed directly into the Cellar site-packages,
since they need to install to a place that supports .pth files.

The pip & distribute formuale use the "site_packages" method defined here
to get the appropriate site-packages path.

COMMENTS


# Was a Framework build requested?
def build_framework?; build.include? 'framework'; end

# Are we installed or installing as a Framework?
def as_framework?
  (self.installed? and File.exists? prefix+"Frameworks/Python.framework") or build_framework?
end

class Python < Formula
  version "26"
  homepage 'http://www.python.org/'
  url 'http://www.python.org/ftp/python/2.6.8/Python-2.6.8.tgz'
  sha1 '104304943eb9f0a34d255f1849bc00f67d3d272f'

  option :universal
  option 'framework', 'Do a Framework build instead of a UNIX-style build'
  option 'static', 'Build static libraries'

  depends_on 'sqlite' => :recommended
  depends_on 'readline' => :recommended
  depends_on 'gdbm' => :recommended

  # Skip binaries so modules will load; skip lib because it is mostly Python files
  skip_clean ['bin', 'lib']

  def site_packages
    # The Cellar location of site-packages
    if as_framework?
      # If we're installed or installing as a Framework, then use that location.
      return prefix+"Frameworks/Python.framework/Versions/2.6/lib/python2.6/site-packages"
    else
      # Otherwise, use just the lib path.
      return lib+"python2.6/site-packages"
    end
  end

  def prefix_site_packages
    # The HOMEBREW_PREFIX location of site-packages
    HOMEBREW_PREFIX+"lib/python2.6/site-packages"
  end

  def validate_options
    if build_framework? and build.include? "static"
      onoe "Cannot specify both framework and static."
      exit 99
    end
  end

  def install
    # Python 2.5-2.7 requires -fwrapv for proper Decimal division with Clang. See:
    # https://github.com/mxcl/homebrew/pull/10487
    # http://stackoverflow.com/questions/7590137/dividing-decimals-yields-invalid-results-in-python-2-5-to-2-7
    # https://trac.macports.org/changeset/87442
    ENV.append 'EXTRA_CFLAGS', '-fwrapv'

    validate_options

    args = ["--prefix=#{prefix}"]

    if build.universal?
      args << "--enable-universalsdk=/" << "--with-universal-archs=intel"
    end

    if build_framework?
      args << "--enable-framework=#{prefix}/Frameworks"
    else
      args << "--enable-shared" unless build.include? 'static'
    end

    system "./configure", *args
    system "make"
    ENV.j1 # Some kinds of installs must be serialized.
    system "make install"

    # Add the Homebrew prefix path to site-packages via a .pth
    prefix_site_packages.mkpath
    (site_packages+"homebrew.pth").write prefix_site_packages
  end

  def caveats
    framework_caveats = <<-EOS.undent
      Framework Python was installed to:
        #{prefix}/Frameworks/Python.framework

      You may want to symlink this Framework to a standard OS X location,
      such as:
        mkdir ~/Frameworks
        ln -s "#{prefix}/Frameworks/Python.framework" ~/Frameworks

    EOS

    site_caveats = <<-EOS.undent
      The site-packages folder for this Python is:
        #{site_packages}

      We've added a "homebrew.pth" file to also include:
        #{prefix_site_packages}

    EOS

    general_caveats = <<-EOS.undent
      You may want to create a "virtual environment" using this Python as a base
      so you can manage multiple independent site-packages. See:
        http://pypi.python.org/pypi/virtualenv

      If you install Python packages via pip, binaries will be installed under
      Python's cellar but not automatically linked into the Homebrew prefix.
      You may want to add Python's bin folder to your PATH as well:
        #{bin}
    EOS

    s = site_caveats+general_caveats
    s = framework_caveats + s if as_framework?
    return s
  end
end
