# frozen_string_literal: true

module Engine::Components
  module UI
    module FlexLayout
      class Pack < Base
        def initialize(direction:, gap:, justify:)
          super(direction: direction, gap: gap)
          @justify = justify
        end

        def rect_for_child(child_ui_rect, index, children, parent_rect)
          sizes = children.map { |c| child_main_size(c) }
          total_content = sizes.sum + total_gap(children)

          available = row? ? parent_rect.width : parent_rect.height
          start_offset = calculate_start_offset(available, total_content, children.length)

          # Y-down: both row and column increment main_start
          main_start = main_axis_start(parent_rect)
          main_start += start_offset

          children.each_with_index do |_, i|
            break if i == index
            main_start += sizes[i] + gap
          end

          build_rect(parent_rect, main_start: main_start, main_size: sizes[index])
        end

        private

        def child_main_size(child_ui_rect)
          size = row? ? child_ui_rect.flex_width : child_ui_rect.flex_height
          unless size
            property = row? ? "flex_width" : "flex_height"
            raise "UI::Rect requires #{property} when parent Flex has justify: :#{@justify}"
          end
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
            0
          when :space_around
            remaining / (child_count * 2.0)
          when :space_evenly
            remaining / (child_count + 1.0)
          else
            0
          end
        end
      end
    end
  end
end
