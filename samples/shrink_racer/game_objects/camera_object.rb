# frozen_string_literal: true

module ShrinkRacer
  module CameraObject
    FAR = 200.0

    def self.create(car)
      Engine::GameObject.create(
        name: "Camera",
        pos: Vector[0, 0, 0],
        rotation: Vector[20, 180, 0],
        components: [
          CarFollower.new(car),
          Engine::Components::PerspectiveCamera.new(fov: 45.0, aspect: 1920.0 / 1080.0, near: 0.1, far: FAR)
        ])
    end

    def self.debug_camera
      Engine::GameObject.create(
        name: "Camera",
        pos: Vector[0, 0, 0],
        rotation: Vector[20, 180, 0],
        components: [
          CameraRotator.new,
          Engine::Components::PerspectiveCamera.new(fov: 45.0, aspect: 1920.0 / 1080.0, near: 0.1, far: FAR)
        ])
    end
  end
end
