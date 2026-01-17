# frozen_string_literal: true

module Engine::Components
  module UI
    class Rect < Engine::Component
      serialize :left_ratio, :right_ratio, :top_ratio, :bottom_ratio,
                :left_offset, :right_offset, :top_offset, :bottom_offset

      attr_reader :left_ratio, :right_ratio, :top_ratio, :bottom_ratio,
                  :left_offset, :right_offset, :top_offset, :bottom_offset

      def awake
        @left_ratio    ||= 0.0
        @right_ratio   ||= 0.0
        @bottom_ratio  ||= 0.0
        @top_ratio     ||= 0.0
        @left_offset   ||= 0
        @right_offset  ||= 0
        @bottom_offset ||= 0
        @top_offset    ||= 0
      end

      def parent_rect
        parent_ui = game_object.parent&.components&.find { |c| c.is_a?(UI::Rect) }
        parent_ui&.computed_rect || screen_rect
      end

      def screen_rect
        Engine::UI::Rect.new(
          left: 0,
          right: Engine::Window.framebuffer_width,
          bottom: 0,
          top: Engine::Window.framebuffer_height
        )
      end

      def computed_rect
        # Check if parent has a layout component
        parent_flex = game_object.parent&.components&.find { |c| c.is_a?(UI::Flex) }
        return parent_flex.rect_for_child(self) if parent_flex

        pr = parent_rect

        Engine::UI::Rect.new(
          left:   pr.left   + (pr.width  * @left_ratio)   + @left_offset,
          right:  pr.right  - (pr.width  * @right_ratio)  - @right_offset,
          bottom: pr.bottom + (pr.height * @bottom_ratio) + @bottom_offset,
          top:    pr.top    - (pr.height * @top_ratio)    - @top_offset
        )
      end
    end
  end
end
