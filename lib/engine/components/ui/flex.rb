# frozen_string_literal: true

module Engine::Components
  module UI
    class Flex < Engine::Component
      serialize :direction, :gap, :justify

      attr_reader :direction, :gap, :justify

      def awake
        @direction ||= :row
        @gap ||= 0
        @justify ||= :stretch
      end

      def start
        @ui_rect = game_object.components.find { |c| c.is_a?(UI::Rect) }
        raise "UI::Flex requires a UI::Rect component on the same GameObject" unless @ui_rect
      end

      def rect_for_child(child_ui_rect)
        children = child_ui_rects
        index = children.index(child_ui_rect)
        return nil unless index

        parent_rect = @ui_rect.computed_rect

        if @justify == :stretch
          rect_for_child_stretch(child_ui_rect, index, children, parent_rect)
        else
          rect_for_child_justify(child_ui_rect, index, children, parent_rect)
        end
      end

      private

      def rect_for_child_stretch(child_ui_rect, index, children, parent_rect)
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

          top = parent_rect.top - (index * (child_height + @gap))

          Engine::UI::Rect.new(
            left: parent_rect.left,
            right: parent_rect.right,
            bottom: top - child_height,
            top: top
          )
        end
      end

      def rect_for_child_justify(child_ui_rect, index, children, parent_rect)
        sizes = children.map { |c| child_main_size(c) }
        total_children_size = sizes.sum
        total_gap = @gap * (children.length - 1)
        total_content = total_children_size + total_gap

        if @direction == :row
          available_space = parent_rect.width
          start_offset = calculate_start_offset(available_space, total_content, children.length)

          left = parent_rect.left + start_offset
          children.each_with_index do |child, i|
            break if i == index
            left += sizes[i] + @gap
          end

          Engine::UI::Rect.new(
            left: left,
            right: left + sizes[index],
            bottom: parent_rect.bottom,
            top: parent_rect.top
          )
        else # :column
          available_space = parent_rect.height
          start_offset = calculate_start_offset(available_space, total_content, children.length)

          top = parent_rect.top - start_offset
          children.each_with_index do |child, i|
            break if i == index
            top -= sizes[i] + @gap
          end

          Engine::UI::Rect.new(
            left: parent_rect.left,
            right: parent_rect.right,
            bottom: top - sizes[index],
            top: top
          )
        end
      end

      def child_main_size(child_ui_rect)
        size = @direction == :row ? child_ui_rect.flex_width : child_ui_rect.flex_height
        raise "UI::Rect requires flex_#{@direction == :row ? 'width' : 'height'} when parent Flex has justify: :#{@justify}" unless size
        size
      end

      def calculate_start_offset(available_space, total_content, child_count)
        remaining = available_space - total_content

        case @justify
        when :start
          0
        when :end
          remaining
        when :center
          remaining / 2.0
        when :space_between
          0 # gaps handled differently
        when :space_around
          remaining / (child_count * 2.0)
        when :space_evenly
          remaining / (child_count + 1.0)
        else
          0
        end
      end

      def child_ui_rects
        @child_ui_rects_cache ||= game_object.children
          .map { |child| child.components.find { |c| c.is_a?(UI::Rect) } }
          .compact
      end

      def invalidate_cache
        @child_ui_rects_cache = nil
      end
    end
  end
end
