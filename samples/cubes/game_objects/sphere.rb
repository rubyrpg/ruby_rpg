# frozen_string_literal: true

module Cubes
  module Sphere
    def self.create_set(pos, rotation, size)
      parent = Sphere.create(pos, rotation, size, [Spinner.new(90)])
      child = Sphere.create(pos, rotation, 1, [Spinner.new(90)])
      second_child = Sphere.create(pos, rotation, 1, [Spinner.new(90)])
      child.parent = parent
      second_child.parent = child

      child.pos = Vector[3, 0, 0]
      second_child.pos = Vector[3, 0, 0]
    end

    def self.create_cluster(pos, rotation, size)
      parent = Engine::GameObject.new(
        "Spheres",
        pos: pos,
        rotation: rotation,
        scale: Vector[1, 1, 1])

      first = Sphere.create(Vector[0, 0, 0], Vector[rand(0..360), rand(0..360), rand(0..360)], size)
      first.parent = parent
      second = Sphere.create(Vector[20, 20, -10], 0, size)
      second.parent = parent
      third = Sphere.create(Vector[30, 0, 10], 0, size)
      third.parent = parent
    end

    def self.create(pos, rotation, size, components = [])
      Engine::GameObject.new(
        "Sphere",
        pos: pos,
        rotation: rotation,
        scale: Vector[1, 1, 1] * size,
        components: [
          Engine::Components::MeshRenderer.new(Engine::Mesh.for("assets/sphere"), material),
          *components
        ]
      )
    end

    private

    def self.material
      @material ||=
        begin
          material = Engine::Material.new(Engine::Shader.colour)
          material.set_vec3("colour", Vector[4.0, 0.4, 4.0])
          material
        end
    end
  end
end
