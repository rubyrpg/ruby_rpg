# frozen_string_literal: true

module Engine
  class TangentCalculator
    attr_reader :vertices, :normals, :texture_coords

    def initialize(vertices, normals, texture_coords)
      @vertices = vertices
      @normals = normals
      @texture_coords = texture_coords
    end

    def calculate_tangents
      delta_pos1 = @vertices[1] - @vertices[0]
      delta_pos2 = @vertices[2] - @vertices[0]

      delta_uv1 = @texture_coords[1] - @texture_coords[0]
      delta_uv2 = @texture_coords[2] - @texture_coords[0]

      if delta_uv1[0] * delta_uv2[1] - delta_uv1[1] * delta_uv2[0] == 0
        return normals.map { |normal| Vector[0, 0, 0] }
      end

      uv_matrix = Matrix[
        [delta_uv1[0], delta_uv1[1]],
        [delta_uv2[0], delta_uv2[1]]
      ]

      world_matrix = Matrix[
        [delta_pos1[0], delta_pos1[1], delta_pos1[2]],
        [delta_pos2[0], delta_pos2[1], delta_pos2[2]]
      ]

      tangent_matrix = uv_matrix.inv * world_matrix

      flat_tangent = Vector[tangent_matrix[0, 0], tangent_matrix[0, 1], tangent_matrix[0, 2]]
      bitangents = normals.map { |normal| normal.cross(flat_tangent).normalize }

      normals.map { |normal| bitangents[0].cross(normal).normalize }
    end
  end
end
