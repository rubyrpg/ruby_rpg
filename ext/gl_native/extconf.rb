# frozen_string_literal: true

require 'mkmf'

# A GL call with no prototype gets an implicit int return, which truncates
# pointers on 64-bit — fail the build instead
$CFLAGS << " -Werror=implicit-function-declaration" unless RUBY_PLATFORM =~ /mswin/

# Find OpenGL
case RUBY_PLATFORM
when /darwin/
  $LDFLAGS << " -framework OpenGL"
  $CFLAGS << " -I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/OpenGL.framework/Headers"
when /linux/
  have_library('GL') or abort "OpenGL not found"
  have_library('GLEW') or abort "GLEW not found (install libglew-dev)"
when /mingw|mswin/
  glew_dir = File.expand_path('../../../vendor/glew-2.2.0-win32', __FILE__)
  $CFLAGS << " -I#{glew_dir}/include"
  $LDFLAGS << " -L#{glew_dir}/lib/Release/x64"
  have_library('opengl32') or abort "OpenGL not found"
  have_library('glew32') or abort "GLEW not found"
end

create_makefile('gl_native')
