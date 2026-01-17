# frozen_string_literal: true

module Engine::Components
  module UI
    class FontRenderer < FontRendererBase
      def ui_renderer?
        true
      end

      def start
        @ui_rect = game_object.components.find { |c| c.is_a?(UI::Rect) }
        raise "UI::FontRenderer requires a UI::Rect component on the same GameObject" unless @ui_rect

        super
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

      def set_shader_model_matrix
        rect = @ui_rect.computed_rect

        # Scale text to match rect height
        # The base quad is 1 unit tall, so scale = rect height
        scale = rect.height

        # Position at left edge of rect, vertically centered
        # The quad is centered at origin, so offset by 0.5 to align left edge
        x = rect.left + (scale * 0.5)
        y = rect.bottom + (scale * 0.5)

        model_matrix = Matrix[
          [scale, 0, 0, 0],
          [0, scale, 0, 0],
          [0, 0, 1, 0],
          [x, y, 0, 1]
        ]

        shader.set_mat4("model", model_matrix)
      end
    end
  end
end
