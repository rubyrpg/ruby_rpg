# frozen_string_literal: true

module Engine
  class QuadMesh
    # Vertex format: pos(3) + uv(2) + normal(3) + tangent(3) + bitangent(3) + extra(6) = 20 floats
    def vertex_data
      @vertex_data ||= [
        # top-left
        -0.5,  0.5, 0.0,   0.0, 0.0,   0.0, 0.0, 1.0,   1.0, 0.0, 0.0,   0.0, 1.0, 0.0,   0.0, 0.0, 0.0,   0.0, 0.0, 0.0,
        # top-right
         0.5,  0.5, 0.0,   1.0, 0.0,   0.0, 0.0, 1.0,   1.0, 0.0, 0.0,   0.0, 1.0, 0.0,   0.0, 0.0, 0.0,   0.0, 0.0, 0.0,
        # bottom-right
         0.5, -0.5, 0.0,   1.0, 1.0,   0.0, 0.0, 1.0,   1.0, 0.0, 0.0,   0.0, 1.0, 0.0,   0.0, 0.0, 0.0,   0.0, 0.0, 0.0,
        # bottom-left
        -0.5, -0.5, 0.0,   0.0, 1.0,   0.0, 0.0, 1.0,   1.0, 0.0, 0.0,   0.0, 1.0, 0.0,   0.0, 0.0, 0.0,   0.0, 0.0, 0.0,
      ]
    end

    def index_data
      @index_data ||= [
        0, 2, 1,
        2, 0, 3
      ]
    end
  end
end
