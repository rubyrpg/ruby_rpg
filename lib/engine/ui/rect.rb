# frozen_string_literal: true

module Engine
  module UI
    Rect = Struct.new(:left, :bottom, :right, :top, keyword_init: true) do
      def width
        right - left
      end

      def height
        # Y-down: bottom > top
        bottom - top
      end
    end
  end
end
