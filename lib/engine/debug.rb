# frozen_string_literal: true

module Engine
  module Debug
    @lines = []
    @spheres = []

    class << self
      def line(from, to, color: [1, 1, 1])
        @lines << { from: from, to: to, color: color }
      end

      def sphere(center, radius, color: [1, 1, 1], segments: 16)
        @spheres << { center: center, radius: radius, color: color, segments: segments }
      end

      def lines
        @lines
      end

      def spheres
        @spheres
      end

      def clear
        @lines.clear
        @spheres.clear
      end
    end
  end
end
