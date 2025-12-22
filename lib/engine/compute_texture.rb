# frozen_string_literal: true

module Engine
  class ComputeTexture
    def self.new(width, height)
      if OS.mac?
        Metal::ComputeTexture.new(width, height)
      else
        OpenGL::ComputeTexture.new(width, height)
      end
    end
  end
end
