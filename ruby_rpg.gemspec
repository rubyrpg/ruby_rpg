Gem::Specification.new do |s|
  s.name = 'ruby_rpg'
  s.version = '0.0.5'
  s.authors = ['Max Hatfull']
  s.email = "max.hatfull@gmail.com"
  s.summary = "A game engine written in Ruby"
  s.description = "A Ruby game engine using OpenGL and GLFW"
  s.files = Dir.glob("{lib,bin}/**/*") +
            Dir.glob("ext/**/*.{rb,c,h}") +
            Dir.glob("vendor/glfw-*/lib-*/*.{dylib,dll}") +
            Dir.glob("vendor/glfw-*/LICENSE.md") +
            ["README.md"]
  s.require_paths = ["lib"]
  s.extensions = Dir.glob("ext/*/extconf.rb")
  s.homepage = "https://github.com/rubyrpg/ruby_rpg"
  s.license = "MIT"
  s.required_ruby_version = '>= 3.3.1'

  s.add_runtime_dependency "native_audio", "~> 0.3.0"
  s.add_runtime_dependency 'concurrent-ruby'
  s.add_runtime_dependency 'os'
  s.add_runtime_dependency 'matrix', '~> 0.3'
  s.add_runtime_dependency 'chunky_png', '~> 1.4'
  s.add_runtime_dependency 'fiddle'
  s.add_runtime_dependency 'logger'

  s.bindir = 'bin'
  s.executables = ['import']

  # Temporarily disabled for Windows CI debugging
  # s.add_runtime_dependency 'rmagick', '~> 6.0', '>= 6.0.1'
end
