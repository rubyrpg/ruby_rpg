# frozen_string_literal: true

module Engine::Components
  class FontRenderer < FontRendererBase
    def renderer?
      true
    end

    private

    def shader
      @shader ||= Engine::Shader.text
    end

    def set_shader_camera_matrix
      shader.set_mat4("camera", Engine::Camera.instance.matrix)
    end
  end
end
