Gem::Specification.new do |s|
  s.name = 'ruby_rpg'
  s.version = '0.1.3'
  s.authors = ['Max Hatfull']
  s.email = "max.hatfull@gmail.com"
  s.summary = "A game engine written in Ruby"
  s.description = "A Ruby game engine using OpenGL and GLFW"
  s.files = Dir.glob("{lib,bin}/**/*") +
            Dir.glob("ext/**/*.{rb,c,h}") +
            Dir.glob("vendor/glfw-*/lib-*/*.{dylib,dll}") +
            Dir.glob("vendor/glfw-*/LICENSE.md") +
            Dir.glob("vendor/glew-*/include/**/*.h") +
            Dir.glob("vendor/glew-*/lib/Release/x64/*.lib") +
            Dir.glob("vendor/glew-*/bin/Release/x64/*.dll") +
            Dir.glob("vendor/glew-*/LICENSE.txt") +
            ["README.md", "THIRD_PARTY_NOTICES.md"]
  s.require_paths = ["lib"]
  s.extensions = Dir.glob("ext/*/extconf.rb")
  s.homepage = "https://github.com/rubyrpg/ruby_rpg"
  s.license = "MIT"
  s.required_ruby_version = '>= 3.3.1'

  s.add_runtime_dependency "native_audio", "~> 0.4.0"
  s.add_runtime_dependency 'concurrent-ruby'
  s.add_runtime_dependency 'os'
  s.add_runtime_dependency 'matrix', '~> 0.3'
  s.add_runtime_dependency 'chunky_png', '~> 1.4'
  s.add_runtime_dependency 'fiddle'
  s.add_runtime_dependency 'logger'

  s.bindir = 'bin'
  s.executables = ['import']
end
