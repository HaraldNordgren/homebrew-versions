class Glfw < Formula
  version "3"
  desc "Multi-platform library for OpenGL applications"
  homepage "http://www.glfw.org/"
  url "https://github.com/glfw/glfw/archive/3.2.1.tar.gz"
  sha256 "e10f0de1384d75e6fc210c53e91843f6110d6c4f3afbfb588130713c2f9d8fe8"

  head "https://github.com/glfw/glfw.git"

  bottle do
    cellar :any
    sha256 "299adbffdf82bc6040b126d317cd90cd6569fe0e4e16ce64fdc06e926797f805" => :el_capitan
    sha256 "e1634c7ad4cde63222d193f91124066575412a2cc4889cccc8768dd977e5acfd" => :yosemite
    sha256 "a276c4098579c17da6105c0d5f9372a5dc7c08189b6fe05b366e20530c582511" => :mavericks
  end

  option :universal
  option "without-shared-library", "Build static library only (defaults to building dylib only)"
  option "with-examples", "Build examples"
  option "with-test", "Build test programs"

  depends_on "cmake" => :build

  deprecated_option "build-examples" => "with-examples"
  deprecated_option "static" => "without-shared-library"
  deprecated_option "build-tests" => "with-test"
  deprecated_option "with-tests" => "with-test"

  def install
    ENV.universal_binary if build.universal?

    # make library name consistent
    inreplace "CMakeLists.txt", /set\(GLFW_LIB_NAME\sglfw\)\n.*else\(\)\n/, ""

    args = std_cmake_args + %w[
      -DGLFW_USE_CHDIR=TRUE
      -DGLFW_USE_MENUBAR=TRUE
    ]
    args << "-DGLFW_BUILD_UNIVERSAL=TRUE" if build.universal?
    args << "-DBUILD_SHARED_LIBS=TRUE" if build.with? "shared-library"
    args << "-DGLFW_BUILD_EXAMPLES=TRUE" if build.with? "examples"
    args << "-DGLFW_BUILD_TESTS=TRUE" if build.with? "test"
    args << "."

    system "cmake", *args
    system "make", "install"
    libexec.install Dir["examples/*"] if build.with? "examples"
    libexec.install Dir["tests/*"] if build.with? "tests"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #define GLFW_INCLUDE_GLU
      #include <GLFW/glfw3.h>
      #include <stdlib.h>
      int main()
      {
        if (!glfwInit())
          exit(EXIT_FAILURE);
        glfwTerminate();
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-L#{lib}", "-lglfw3",
           testpath/"test.c", "-o", "test"
    system "./test"
  end
end
