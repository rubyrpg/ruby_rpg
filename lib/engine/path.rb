# frozen_string_literal: true

module Engine
  class NoEarsException < StandardError; end

  class Path
    attr_reader :points

    def initialize(points)
      optimised_points = remove_colinear(points)
      if optimised_points.length <= 3
        @points = points
      else
        @points = optimised_points
      end
      #@points = points
    end

    def point_string(p)
      "#{20 * (p[0] + 3)}, #{50 * (p[1] + 2)}"
    end

    def length
      points.length
    end

    def find_ear
      triangles = points.map.with_index do |point, i|
        a = points[i - 1]
        b = point
        c = points[(i + 1) % points.length]
        [a, b, c]
      end

      triangles.each do |triangle|
        if is_ear?(triangle)
          new_points = points.reject { |point| point == triangle[1] }
          return triangle, Path.new(new_points)
        end
      end
      raise NoEarsException
    end

    def is_ear?(triangle)
      return false unless clockwise?(triangle)
      points.each do |point|
        next if triangle.include?(point)
        return false if point_in_triangle?(point, triangle)
      end
      true
    end

    private

    def remove_colinear(points)
      points.reject.with_index do |point, i|
        a = points[i - 1]
        b = point
        c = points[(i + 1) % points.length]

        cross_product(a, b, c).zero?
      end
    end

    def anti_clockwise?(triangle)
      a, b, c = triangle
      cross_product = (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
      cross_product > 0
    end

    def clockwise?(triangle)
      !anti_clockwise?(triangle)
    end

    def point_in_triangle?(point, triangle)
      a, b, c = triangle
      pab = cross_product(point, a, b)
      pbc = cross_product(point, b, c)
      pca = cross_product(point, c, a)

      same_sign?(pab, pbc) && same_sign?(pbc, pca)
    end

    def cross_product(a, b, c)
      (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
    end

    def same_sign?(a, b)
      a.negative? == b.negative?
    end
  end
end
