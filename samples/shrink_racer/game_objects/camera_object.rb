# frozen_string_literal: true

module ShrinkRacer
  module CameraObject
    FAR = 200.0

    def self.create(car)
      back_plane = create_back_plane
      camera = Engine::GameObject.new(
        "Camera",
        pos: Vector[0, 0, 0],
        rotation: Vector[20, 180, 0],
        components: [
          CarFollower.new(car),
          Engine::Components::PerspectiveCamera.new(fov: 45.0, aspect: 1920.0 / 1080.0, near: 0.1, far: FAR)
        ])
      back_plane.parent = camera
      camera
    end

    def self.debug_camera
      back_plane = create_back_plane
      camera = Engine::GameObject.new(
        "Camera",
        pos: Vector[0, 0, 0],
        rotation: Vector[20, 180, 0],
        components: [
          CameraRotator.new,
          Engine::Components::PerspectiveCamera.new(fov: 45.0, aspect: 1920.0 / 1080.0, near: 0.1, far: FAR)
        ])
      back_plane.parent = camera
      camera
    end

    private

    def self.create_back_plane
      material = Engine::Material.new(Engine::Shader.skybox)
      Engine::GameObject.new(
        "Skybox",
        pos: Vector[0, 0, -FAR + 20],
        scale: Vector[FAR, FAR, 1],
        rotation: Vector[0, 180, 0],
        components: [
          Engine::Components::MeshRenderer.new(
            Engine::Mesh.for("assets/quad"),
            material
          )
        ]
      )
    end
  end
end
