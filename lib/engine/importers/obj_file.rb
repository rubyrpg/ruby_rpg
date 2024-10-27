# frozen_string_literal: true

module Engine
  class ObjFile
    def initialize(file_path)
      @mesh_data = File.readlines(file_path + ".obj")
      if File.exist?(file_path + ".mtl")
        @mtl_data = File.readlines(file_path + ".mtl").map(&:chomp)
      else
        @mtl_data = []
      end
    end

    def vertices
      @vertices ||=
        @mesh_data.select { |line| line.start_with?("v ") }.map do |line|
          _, x, y, z = line.split(" ")
          Vector[x.to_f, y.to_f, z.to_f]
        end
    end

    def normals
      @normals ||=
        @mesh_data.select { |line| line.start_with?("vn ") }.map do |line|
          _, x, y, z = line.split(" ")
          Vector[x.to_f, y.to_f, z.to_f]
        end
    end

    def tangents
      @tangents ||=
        (0...vertex_indices.length).each_slice(3).map do |i1, i2, i3|
          vertex1 = vertices[vertex_indices[i1]]
          normal1 = normals[normal_indices[i1]]
          texture_coord1 = texture_coords[texture_indices[i1]]

          vertex2 = vertices[vertex_indices[i2]]
          normal2 = normals[normal_indices[i2]]
          texture_coord2 = texture_coords[texture_indices[i2]]

          vertex3 = vertices[vertex_indices[i3]]
          normal3 = normals[normal_indices[i3]]
          texture_coord3 = texture_coords[texture_indices[i3]]

          triangle_vertices = [vertex1, vertex2, vertex3]
          triangle_normals = [normal1, normal2, normal3]
          triangle_texture_coords = [texture_coord1, texture_coord2, texture_coord3]

          Engine::TangentCalculator.new(triangle_vertices, triangle_normals, triangle_texture_coords).calculate_tangents
        end.flatten(1)
    end

    def texture_coords
      @texture_coords ||=
        @mesh_data.select { |line| line.start_with?("vt ") }.map do |line|
          _, x, y = line.split(" ")
          Vector[x.to_f, y.to_f]
        end
    end

    def face_lines
      @face_lines ||=
        begin
          split_faces(@mesh_data).select { |line| line.start_with?("f ") }
        end
    end

    def split_faces(lines)
      lines.map.with_index do |line, line_number|
        if line.start_with?("f ")
          new_faces = split_face(line)
          (new_faces.length * 3).times do
            material_names << material_for_line(line_number)
          end
          new_faces
        else
          line
        end
      end.flatten
    end

    def split_face(face)
      face_vertices = face.split(" ")[1..-1]
      return [face] if face_vertices.length == 3

      world_points = face_vertices.map { |v| v.split("/")[0] }
              .map { |i| vertices[i.to_i - 1] }
      plane = plane_matrix(world_points)
      flat_points = world_points.map { |point| plane * point }
      packed_points = face_vertices.map.with_index do |v, i|
        { point_string: face_vertices[i], 0 => flat_points[i][0], 1 => flat_points[i][1] }
      end

      path = Path.new(packed_points.reverse)
      begin
        decompose_path(path, true)
      rescue NoEarsException
        decompose_path(Path.new(packed_points), false)
      end
    end

    def decompose_path(path, reverse)
      decomposed_vertices = []
      depth = 100
      until path.length == 3 || depth == 0
        depth -= 1
        ear_result = path.find_ear
        ear = ear_result.first
        new_path = ear_result.last
        ear = ear.reverse! if reverse
        ear_area = triangle_area(ear[0], ear[1], ear[2])
        decomposed_vertices << ear unless ear_area < 0.0001
        path = new_path
      end
      if reverse
        decomposed_vertices << path.points.reverse
      else
        decomposed_vertices << path.points
      end
      decomposed_vertices.map do |triangle|
        "f #{triangle.map { |v| v[:point_string] }.join(" ")}"
      end
    end

    def triangle_area(a, b, c)
      (a[0] * (b[1] - c[1]) + b[0] * (c[1] - a[1]) + c[0] * (a[1] - b[1])).abs / 2.0
    end

    def plane_matrix(points)
      raise "Not enough points to create a plane" if points.length < 3

      origin_point = points[0]
      a = points[1] - origin_point
      b = nil
      points[2..-1].each do |point|
        diff = point - origin_point
        b = diff if a.cross(diff).magnitude > 0.0001
      end
      raise "Points are collinear" if b.nil?

      normal = a.cross(b).normalize

      Matrix[
        [a[0], a[1], a[2]],
        [b[0], b[1], b[2]],
        [normal[0], normal[1], normal[2]]
      ].transpose.inverse
    end

    def vertex_indices
      @vertex_indices ||=
        face_lines.map do |line|
          _, v1, v2, v3 = line.split(" ")
          v1, v2, v3 = [v1, v2, v3].map { |v| v.split("/").first.to_i }
          [v1 - 1, v2 - 1, v3 - 1]
        end.flatten
    end

    def texture_indices
      @texture_indices ||=
        face_lines.map do |line|
          _, v1, v2, v3 = line.split(" ")
          v1, v2, v3 = [v1, v2, v3].map { |v| v.split("/")[1].to_i }
          [v1 - 1, v2 - 1, v3 - 1]
        end.flatten
    end

    def normal_indices
      @normal_indices ||=
        face_lines.map do |line|
          _, v1, v2, v3 = line.split(" ")
          v1, v2, v3 = [v1, v2, v3].map { |v| v.split("/")[2].to_i }
          [v1 - 1, v2 - 1, v3 - 1]
        end.flatten
    end


    def material_for_line(line_number)
      l = line_number
      until l == 0
        if @mesh_data[l].start_with?("usemtl ")
          return @mesh_data[l].split(" ")[1]
        end
        l -= 1
      end
    end

    def material_names
      @material_names ||= []
    end

    def materials
      @materials ||=
        begin
          current_material = nil
          @mtl_data.each_with_object({}) do |line, materials|
            if line.start_with?("newmtl ")
              _, material_name = line.split(" ")
              current_material = material_name
              materials[material_name] = {}
            elsif line.start_with?("Kd ")
              _, r, g, b = line.split(" ")
              materials[current_material][:diffuse] = Vector[r.to_f, g.to_f, b.to_f]
            elsif line.start_with?("Ks ")
              _, r, g, b = line.split(" ")
              materials[current_material][:specular] = Vector[r.to_f, g.to_f, b.to_f]
            elsif line.start_with?("Ka ")
              _, r, g, b = line.split(" ")
              materials[current_material][:albedo] = Vector[r.to_f, g.to_f, b.to_f]
            end
          end
        end
    end

    def vertex_data
      @vertex_data ||=
        (0...vertex_indices.length).map do |i|
          {
            vertex: vertices[vertex_indices[i]],
            normal: normals[normal_indices[i]],
            texture_coord: texture_coords[texture_indices[i]],
            tangent: tangents[i],
            diffuse: materials.dig(material_names[i], :diffuse) || Vector[1, 1, 1],
            specular: materials.dig(material_names[i], :specular) || Vector[1, 1, 1],
            albedo: materials.dig(material_names[i], :albedo) || Vector[1, 1, 1],
          }
        end.map do |data|
          [
            data[:vertex][0], data[:vertex][1], data[:vertex][2],
            data[:texture_coord][0], data[:texture_coord][1],
            data[:normal][0], data[:normal][1], data[:normal][2],
            data[:tangent][0].to_f, data[:tangent][1].to_f, data[:tangent][2].to_f,
            data[:diffuse][0], data[:diffuse][1], data[:diffuse][2],
            data[:specular][0], data[:specular][1], data[:specular][2],
            data[:albedo][0], data[:albedo][1], data[:albedo][2],
          ]
        end.flatten
    end

    def index_data
      @index_data ||= (0...vertex_indices.length).map(&:to_i)
    end
  end
end
