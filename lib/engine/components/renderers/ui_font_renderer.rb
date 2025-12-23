# frozen_string_literal: true

module Engine::Components
  class UIFontRenderer < FontRendererBase
    def ui_renderer?
      true
    end

    private

    def shader
      @shader ||= Engine::Shader.ui_text
    end

    def set_shader_camera_matrix
      camera_matrix = Matrix[
        [2.0 / Engine::Window.framebuffer_width, 0, 0, 0],
        [0, 2.0 / Engine::Window.framebuffer_height, 0, 0],
        [0, 0, 1, 0],
        [-1, -1, 0, 1]
      ]
      shader.set_mat4("camera", camera_matrix)
    end
  end
end
