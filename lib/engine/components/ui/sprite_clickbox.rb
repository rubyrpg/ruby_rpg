# frozen_string_literal: true

module Engine::Components
  module UI
    class SpriteClickbox < Engine::Component
      attr_reader :mouse_inside, :clicked, :mouse_entered, :mouse_exited

      def awake
        @mouse_inside = false
        @clicked = false
        @mouse_entered = false
        @mouse_exited = false
      end

      def start
        @ui_rect = game_object.component(UI::Rect)
        raise "UI::SpriteClickbox requires a UI::Rect component" unless @ui_rect
      end

      def update(delta_time)
        mouse_pos = Engine::Input.mouse_pos
        return unless mouse_pos

        if point_inside?(mouse_pos)
          @mouse_entered = !@mouse_inside
          @mouse_inside = true
          @clicked = Engine::Input.key_down?(GLFW::MOUSE_BUTTON_LEFT)
        else
          @mouse_exited = @mouse_inside
          @mouse_inside = false
        end
      end

      private

      def point_inside?(point)
        rect = @ui_rect.computed_rect

        # Y-down: top < bottom
        point[0] >= rect.left &&
          point[0] <= rect.right &&
          point[1] >= rect.top &&
          point[1] <= rect.bottom
      end
    end
  end
end
