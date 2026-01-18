# frozen_string_literal: true

module Engine::Components
  module UI
    module FlexLayout
      class Base
        def initialize(direction:, gap:)
          @direction = direction
          @gap = gap
        end

        def rect_for_child(child_ui_rect, index, children, parent_rect)
          raise NotImplementedError
        end

        private

        attr_reader :direction, :gap

        def row?
          @direction == :row
        end

        def main_axis_size(rect)
          row? ? rect.width : rect.height
        end

        def total_gap(children)
          @gap * (children.length - 1)
        end

        def build_rect(parent_rect, main_start:, main_size:, child_ui_rect: nil)
          # Y-down coordinate system: both row and column increment main_start
          if row?
            # Cross-axis is vertical; use flex_height if specified, else stretch
            cross_size = child_ui_rect&.flex_height
            top = parent_rect.top
            bottom = cross_size ? top + cross_size : parent_rect.bottom

            Engine::UI::Rect.new(
              left: main_start,
              right: main_start + main_size,
              top: top,
              bottom: bottom
            )
          else
            # Cross-axis is horizontal; use flex_width if specified, else stretch
            cross_size = child_ui_rect&.flex_width
            left = parent_rect.left
            right = cross_size ? left + cross_size : parent_rect.right

            Engine::UI::Rect.new(
              left: left,
              right: right,
              top: main_start,
              bottom: main_start + main_size
            )
          end
        end

        def main_axis_start(parent_rect)
          row? ? parent_rect.left : parent_rect.top
        end

        def available_space(parent_rect, children)
          size = row? ? parent_rect.width : parent_rect.height
          size - total_gap(children)
        end
      end
    end
  end
end
