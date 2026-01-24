# frozen_string_literal: true

require 'mkmf'

# We use dlopen to dynamically load GLFW at runtime, so no library linking needed
# Just need to compile with position-independent code

case RUBY_PLATFORM
when /darwin/
  # macOS: we'll dlopen the bundled libglfw.3.dylib
  $LDFLAGS << " -ldl"
when /linux/
  $LDFLAGS << " -ldl"
when /mingw|mswin/
  # Windows uses LoadLibrary, no extra flags needed
end

create_makefile('glfw_native')
