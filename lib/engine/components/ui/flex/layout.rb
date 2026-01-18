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

        def build_rect(parent_rect, main_start:, main_size:)
          if row?
            Engine::UI::Rect.new(
              left: main_start,
              right: main_start + main_size,
              bottom: parent_rect.bottom,
              top: parent_rect.top
            )
          else
            Engine::UI::Rect.new(
              left: parent_rect.left,
              right: parent_rect.right,
              bottom: main_start - main_size,
              top: main_start
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
