# frozen_string_literal: true

module Engine
  module Debug
    @lines = []

    class << self
      def line(from, to, color: [1, 1, 1])
        @lines << { from: from, to: to, color: color }
      end

      def lines
        @lines
      end

      def clear
        @lines.clear
      end
    end
  end
end
