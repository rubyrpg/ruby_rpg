# frozen_string_literal: true

require 'mkmf'

# Find OpenGL
case RUBY_PLATFORM
when /darwin/
  $LDFLAGS << " -framework OpenGL"
  $CFLAGS << " -I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/OpenGL.framework/Headers"
when /linux/
  have_library('GL') or abort "OpenGL not found"
when /mingw|mswin/
  have_library('opengl32') or abort "OpenGL not found"
end

create_makefile('gl_native')
