# frozen_string_literal: true

module Engine
  class PolygonMesh
    attr_reader :points, :uvs

    def initialize(points, uvs)
      @points = points
      @uvs = uvs
    end

    def vertex_data
      @vertex_data ||= generate_vertex_data
    end

    def index_data
      @index_data ||= (0..vertices.length - 1).to_a
    end

    private

    def generate_vertex_data
      vertices.map do |point|
        uv = uvs[points.index(point)]
        [point[0], point[1], 0.0, uv[0], uv[1]]
      end.flatten
    end

    def vertices
      @vertices ||=
        begin
          path = Path.new(@points)
          vertices = []
          until path.length == 3
            ear, new_path = path.find_ear
            ear = ear.reverse!
            vertices << ear
            path = new_path
          end
          vertices += path.points.reverse
          vertices.flatten(1)
        end
    end
  end
end
