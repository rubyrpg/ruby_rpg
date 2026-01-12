# frozen_string_literal: true

module ShrinkRacer
  module Car
    def self.create_suv(pos, rotation)
      spinner = SpinEffect.create
      parent = Engine::GameObject.create(
        name: "Car",
        pos: pos,
        rotation: rotation,
        scale: Vector[0.1, 0.1, 0.1],
        components: [
          CarCollider.new(1.0),
          CarController.new(spinner),
        ]
      )
      Engine::GameObject.create(
        name: "SUV",
        pos: Vector[0, 0, 0],
        rotation: Vector[0, 0, 0],
        scale: Vector[1, 1, 1],
        components: [
          spinner,
          Engine::Components::MeshRenderer.new(Engine::Mesh.for(
            "assets/cars/suv"), material),
        ],
        parent: parent
      )

      # Headlights
      Engine::GameObject.create(
        name: "Headlight Left",
        pos: Vector[-0.75, 1, 0],
        rotation: Vector[0, 0, 0],
        parent: parent,
        components: [
          Engine::Components::SpotLight.create(
            range: 30,
            colour: Vector[0.03, 0.028, 0.024],
            inner_angle: 0,
            outer_angle: 10,
            cast_shadows: true
          )
        ]
      )
      Engine::GameObject.create(
        name: "Headlight Right",
        pos: Vector[0.75, 1, 0],
        rotation: Vector[0, 0, 0],
        parent: parent,
        components: [
          Engine::Components::SpotLight.create(
            range: 30,
            colour: Vector[0.03, 0.028, 0.024],
            inner_angle: 0,
            outer_angle: 10,
            cast_shadows: true
          )
        ]
      )

      parent
    end

    private

    def self.material
      @material ||=
        begin
          material = Engine::Material.create(shader: Engine::Shader.default)
          material.set_texture("image", Engine::Texture.for("assets/cars/Textures/colormap.png", flip: true))
          material.set_texture("normalMap", nil)
          material.set_float("diffuseStrength", 0.5)
          material.set_float("specularStrength", 0.6)
          material.set_float("specularPower", 32.0)
          material.set_vec3("ambientLight", Vector[0.25, 0.2, 0.35])
          material
        end
    end
  end
end
