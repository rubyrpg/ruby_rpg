# frozen_string_literal: true

module Engine
  class ComputeShader
    def self.new(shader_path)
      if OS.mac?
        metal_path = shader_path.sub(/\.(comp|glsl)$/, '.metal')
        Metal::ComputeShader.new(metal_path)
      else
        OpenGL::ComputeShader.new(shader_path)
      end
    end
  end
end
