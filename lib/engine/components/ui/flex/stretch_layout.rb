# frozen_string_literal: true

module Engine::Components
  module UI
    module FlexLayout
      class Stretch < Base
        def rect_for_child(child_ui_rect, index, children, parent_rect)
          sizes = calculate_sizes(children, parent_rect)

          # Y-down: both row and column increment main_start
          main_start = main_axis_start(parent_rect)
          children.each_with_index do |_, i|
            break if i == index
            main_start += sizes[i] + gap
          end

          build_rect(parent_rect, main_start: main_start, main_size: sizes[index])
        end

        private

        def calculate_sizes(children, parent_rect)
          available = available_space(parent_rect, children)

          fixed_total = 0
          total_weight = 0

          children.each do |child|
            fixed_size = row? ? child.flex_width : child.flex_height
            if fixed_size
              fixed_total += fixed_size
            else
              total_weight += child.flex_weight || 1
            end
          end

          remaining = available - fixed_total
          per_weight = total_weight > 0 ? remaining / total_weight.to_f : 0

          children.map do |child|
            fixed_size = row? ? child.flex_width : child.flex_height
            if fixed_size
              fixed_size
            else
              (child.flex_weight || 1) * per_weight
            end
          end
        end
      end
    end
  end
end
