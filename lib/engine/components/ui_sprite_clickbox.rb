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
      @renderer = game_object.ui_renderers.find { |r| r.is_a?(Engine::Components::UISpriteRenderer) }
      raise "UISpriteClickbox requires a UISpriteRenderer" unless @renderer
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
      local_point = game_object.world_to_local_coordinate(Vector[point[0], point[1], 0])
      local_point = Vector[local_point[0], local_point[1]]

      tl = @renderer.v1
      tr = @renderer.v2
      br = @renderer.v3
      bl = @renderer.v4

      point_in_triangle(local_point, tl, tr, br) ||
        point_in_triangle(local_point, tl, br, bl)
    end

    def point_in_triangle(point, v1, v2, v3)
      mapped_point = point - v1
      mapped_v2 = v2 - v1
      mapped_v3 = v3 - v1

      matrix = Matrix[
        [mapped_v2[0], mapped_v3[0]],
        [mapped_v2[1], mapped_v3[1]]
      ]

      remapped_point = matrix.inverse * mapped_point
      remapped_point[0] >= 0 && remapped_point[1] >= 0 && remapped_point[0] + remapped_point[1] <= 1
    end
  end
end
