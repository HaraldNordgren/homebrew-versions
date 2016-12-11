require 'formula'

class Glfw < Formula
  version "3"
  homepage 'http://www.glfw.org/'
  url 'http://downloads.sourceforge.net/project/glfw/glfw/3.0.3/glfw-3.0.3.tar.bz2'
  sha1 'a2361a82d415b39775a324a8c79099bf9f4fd27d'

  depends_on 'cmake' => :build

  option :universal
  option :static, 'Build static library only (defaults to building dylib only)'
  option :'build-examples', 'Build examples'
  option :'build-tests', 'Build test programs'

  def patches
    # make library name consistent
    # Fix conflicting typedefs
    DATA
  end

  def install
    ENV.universal_binary if build.universal?

    args = std_cmake_args + %W[
      -DGLFW_USE_CHDIR=TRUE
      -DGLFW_USE_MENUBAR=TRUE
    ]
    args << '-DGLFW_BUILD_UNIVERSAL=TRUE' if build.universal?
    args << '-DBUILD_SHARED_LIBS=TRUE' unless build.include? 'static'
    args << '-DGLFW_BUILD_EXAMPLES=TRUE' if build.include? 'build-examples'
    args << '-DGLFW_BUILD_TESTS=TRUE' if build.include? 'build-tests'
    args << '.'

    system 'cmake', *args
    system 'make', 'install'
  end
end

__END__
diff -u a/CMakeLists.txt b/CMakeLists.txt
index
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -357,12 +357,7 @@
 #--------------------------------------------------------------------
 # Choose library output name
 #--------------------------------------------------------------------
-if (BUILD_SHARED_LIBS AND UNIX)
-    # On Unix-like systems, shared libraries can use the soname system.
-    set(GLFW_LIB_NAME glfw)
-else()
-    set(GLFW_LIB_NAME glfw3)
-endif()
+set(GLFW_LIB_NAME glfw3)
 
 #--------------------------------------------------------------------
 # Add subdirectories
diff --git a/deps/GL/glext.h b/deps/GL/glext.h
index 6cd79a2..acb4698 100644
--- a/deps/GL/glext.h
+++ b/deps/GL/glext.h
@@ -4130,8 +4130,13 @@
 
 #ifndef GL_ARB_vertex_buffer_object
 #define GL_ARB_vertex_buffer_object 1
+#if defined(__APPLE__)
+typedef long GLsizeiptrARB;
+typedef long GLintptrARB;
+#else
 typedef ptrdiff_t GLsizeiptrARB;
 typedef ptrdiff_t GLintptrARB;
+#endif
 #define GL_BUFFER_SIZE_ARB                0x8764
 #define GL_BUFFER_USAGE_ARB               0x8765
 #define GL_ARRAY_BUFFER_ARB               0x8892
