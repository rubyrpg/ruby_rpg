# frozen_string_literal: true

module Engine::Components
  class UIFlex < Engine::Component
    serialize :direction, :gap

    attr_reader :direction, :gap

    def awake
      @direction ||= :row
      @gap ||= 0
    end

    def start
      @ui_rect = game_object.components.find { |c| c.is_a?(UIRect) }
      raise "UIFlex requires a UIRect component on the same GameObject" unless @ui_rect
    end

    def rect_for_child(child_ui_rect)
      children = child_ui_rects
      index = children.index(child_ui_rect)
      return nil unless index

      parent_rect = @ui_rect.computed_rect
      child_count = children.length
      total_gap = @gap * (child_count - 1)

      if @direction == :row
        available_width = parent_rect.width - total_gap
        child_width = available_width / child_count

        left = parent_rect.left + (index * (child_width + @gap))

        Engine::UI::Rect.new(
          left: left,
          right: left + child_width,
          bottom: parent_rect.bottom,
          top: parent_rect.top
        )
      else # :column
        available_height = parent_rect.height - total_gap
        child_height = available_height / child_count

        # Stack from top to bottom
        top = parent_rect.top - (index * (child_height + @gap))

        Engine::UI::Rect.new(
          left: parent_rect.left,
          right: parent_rect.right,
          bottom: top - child_height,
          top: top
        )
      end
    end

    private

    def child_ui_rects
      @child_ui_rects_cache ||= game_object.children
        .map { |child| child.components.find { |c| c.is_a?(UIRect) } }
        .compact
    end

    def invalidate_cache
      @child_ui_rects_cache = nil
    end
  end
end
