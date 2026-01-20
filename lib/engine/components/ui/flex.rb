# frozen_string_literal: true

require_relative "flex/layout"
require_relative "flex/stretch_layout"
require_relative "flex/pack_layout"

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
        @ui_rect = game_object.component(UI::Rect)
        raise "UI::Flex requires a UI::Rect component on the same GameObject" unless @ui_rect
      end

      def rect_for_child(child_ui_rect)
        children = child_ui_rects
        index = children.index(child_ui_rect)
        return nil unless index

        parent_rect = @ui_rect.computed_rect
        layout.rect_for_child(child_ui_rect, index, children, parent_rect)
      end

      private

      def layout
        @layout ||= create_layout
      end

      def create_layout
        if @justify == :stretch
          FlexLayout::Stretch.new(direction: @direction, gap: @gap)
        else
          FlexLayout::Pack.new(direction: @direction, gap: @gap, justify: @justify)
        end
      end

      def child_ui_rects
        @child_ui_rects_cache ||= game_object.children
          .map { |child| child.component(UI::Rect) }
          .compact
      end

      def invalidate_cache
        @child_ui_rects_cache = nil
        @layout = nil
      end
    end
  end
end
