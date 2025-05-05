Gem::Specification.new do |s|
  s.name = 'ruby_rpg'
  s.version = '0.0.5'
  s.authors = ['Max Hatfull']
  s.email = "max.hatfull@gmail.com"
  s.summary = "A game engine written in Ruby"
  s.description = "A Ruby game engine using OpenGL and GLFW"
  s.files = Dir.glob("{lib,glfw-3.3.9.bin.MACOS,glfw-3.4.bin.WIN64,bin}/**/*") + ["README.md"]
  s.require_paths = ["lib"]
  s.homepage = "https://github.com/rubyrpg/ruby_rpg"
  s.license = "MIT"
  s.required_ruby_version = '>= 3.3.1'

  s.add_runtime_dependency "native_audio"
  s.add_runtime_dependency 'opengl-bindings2', '~> 2.0'
  s.add_runtime_dependency 'concurrent-ruby'
  s.add_runtime_dependency 'os'
  s.add_runtime_dependency 'matrix', '~> 0.3'
  s.add_runtime_dependency 'chunky_png', '~> 1.4'

  s.bindir = 'bin'
  s.executables = ['import']

  s.add_runtime_dependency 'rmagick', '~> 6.0', '>= 6.0.1'
end
