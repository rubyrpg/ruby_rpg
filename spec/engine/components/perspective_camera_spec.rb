# frozen_string_literal: true

describe Engine::Components::PerspectiveCamera do
  describe "when mapping a point to the screen" do
    context "when the camera is at the origin" do
      it "maps the point to the correct screen position" do
        camera = Engine::Components::PerspectiveCamera.create(fov: 90.0, aspect: 1.0, near: 1.0, far: 10.0)
        Engine::GameObject.create(name: "Camera",
                               pos: Vector[0, 0, 0],
                               rotation: Vector[0, 0, 0],
                               scale: Vector[1, 1, 1],
                               components: [camera]
        )

        expect(Vector[0, 0, -1]).to be_on_screen_at(Vector[0, 0, -1])
        expect(Vector[1, 1, -1]).to be_on_screen_at(Vector[1, 1, -1])
        expect(Vector[-1, -1, -1]).to be_on_screen_at(Vector[-1, -1, -1])

        expect(Vector[0, 0, -10]).to be_on_screen_at(Vector[0, 0, 1])
        expect(Vector[10, 10, -10]).to be_on_screen_at(Vector[1, 1, 1])
        expect(Vector[-10, -10, -10]).to be_on_screen_at(Vector[-1, -1, 1])
      end
    end
  end

  describe "#projection" do
    it "projects points correctly" do
      camera = Engine::Components::PerspectiveCamera.create(fov: 90, aspect: 1, near: 1.0, far: 10.0)
      Engine::GameObject.create(name: "Camera",
                             pos: Vector[0, 0, 0],
                             rotation: Vector[0, 0, 0],
                             scale: Vector[1, 1, 1],
                             components: [camera]
      )

      expect(camera.projection * Vector[0, 0, -1, 1]).to be_vector(Vector[0, 0, -1, 1])
      expect(camera.projection * Vector[0, 0, -10, 1]).to be_vector(Vector[0, 0, 10, 10])

      expect(camera.projection * Vector[1, 1, -1, 1]).to be_vector(Vector[1, 1, -1, 1])
      expect(camera.projection * Vector[1, 1, -10, 1]).to be_vector(Vector[1, 1, 10, 10])
    end

    it "projects points correctly when the fov is 45" do
      camera = Engine::Components::PerspectiveCamera.create(fov: 53.1301024, aspect: 1, near: 1.0, far: 10.0)
      Engine::GameObject.create(name: "Camera",
                             pos: Vector[0, 0, 0],
                             rotation: Vector[0, 0, 0],
                             scale: Vector[1, 1, 1],
                             components: [camera]
      )

      expect(camera.projection * Vector[0, 0, -1, 1]).to be_vector(Vector[0, 0, -1, 1])
      expect(camera.projection * Vector[0, 0, -10, 1]).to be_vector(Vector[0, 0, 10, 10])

      expect(camera.projection * Vector[1, 1, -1, 1]).to be_vector(Vector[2, 2, -1, 1])
      expect(camera.projection * Vector[1, 1, -10, 1]).to be_vector(Vector[2, 2, 10, 10])
    end
  end
end