# frozen_string_literal: true

module Engine::Components
  class UISpriteClickbox < Engine::Component
    attr_reader :mouse_inside, :clicked, :mouse_entered, :mouse_exited

    def awake
      @mouse_inside = false
      @clicked = false
      @mouse_entered = false
      @mouse_exited = false
    end

    def start
      @ui_rect = game_object.components.find { |c| c.is_a?(UIRect) }
      raise "UISpriteClickbox requires a UIRect component" unless @ui_rect
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

      point[0] >= rect.left &&
        point[0] <= rect.right &&
        point[1] >= rect.bottom &&
        point[1] <= rect.top
    end
  end
end
