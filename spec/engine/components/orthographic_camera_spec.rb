# frozen_string_literal: true

describe Engine::Components::OrthographicCamera do
  describe "when the camera has a parent" do
    it "invalidates cached matrix when parent moves" do
      camera = Engine::Components::OrthographicCamera.create(width: 10, height: 10, far: 10)
      parent = Engine::GameObject.create(pos: Vector[0, 0, 0])
      child = Engine::GameObject.create(
        pos: Vector[0, 0, 0],
        parent: parent,
        components: [camera]
      )

      # Get initial matrix (caches it)
      initial_matrix = camera.matrix

      # Move the parent
      parent.x = 100

      # Simulate a frame update - this is where the cache should be invalidated
      camera.update(0.016)

      # The camera matrix should now reflect the parent's new position
      updated_matrix = camera.matrix

      expect(updated_matrix).not_to eq(initial_matrix)
    end
  end

  describe "#matrix" do
    it "returns the correct matrix with no position or rotation" do
      camera = Engine::Components::OrthographicCamera.create(width: 10, height: 10, far: 10)
      Engine::GameObject.create(name: "Camera",
                             pos: Vector[0, 0, 0],
                             rotation: Vector[0, 0, 0],
                             scale: Vector[1, 1, 1],
                             components: [camera]
      )

      expect(camera.matrix).to eq(Matrix[
                                    [0.2, 0, 0, 0],
                                    [0, 0.2, 0, 0],
                                    [0, 0, -0.2, 0],
                                    [0, 0, -1, 1]
                                  ])
    end

    it "returns the correct matrix when the camera is at x = 5" do
      camera = Engine::Components::OrthographicCamera.create(width: 10, height: 10, far: 10)
      Engine::GameObject.create(name: "Camera",
                             pos: Vector[5, 0, 0],
                             rotation: Vector[0, 0, 0],
                             scale: Vector[1, 1, 1],
                             components: [camera]
      )

      expect(camera.matrix).to eq(Matrix[
                                    [0.2, 0, 0, 0],
                                    [0, 0.2, 0, 0],
                                    [0, 0, -0.2, 0],
                                    [-1, 0, -1, 1]
                                  ])
    end

    it "returns the correct matrix when the camera is at y = 5" do
      camera = Engine::Components::OrthographicCamera.create(width: 10, height: 10, far: 10)
      Engine::GameObject.create(name: "Camera",
                             pos: Vector[0, 5, 0],
                             rotation: Vector[0, 0, 0],
                             scale: Vector[1, 1, 1],
                             components: [camera]
      )

      expect(camera.matrix).to eq(Matrix[
                                    [0.2, 0, 0, 0],
                                    [0, 0.2, 0, 0],
                                    [0, 0, -0.2, 0],
                                    [0, -1, -1, 1]
                                  ])
    end

    it "returns the correct matrix when the camera is at z = 5" do
      camera = Engine::Components::OrthographicCamera.create(width: 10, height: 10, far: 10)
      Engine::GameObject.create(name: "Camera",
                             pos: Vector[0, 0, 5],
                             rotation: Vector[0, 0, 0],
                             scale: Vector[1, 1, 1],
                             components: [camera]
      )

      expect(camera.matrix).to eq(Matrix[
                                    [0.2, 0, 0, 0],
                                    [0, 0.2, 0, 0],
                                    [0, 0, -0.2, 0],
                                    [0, 0, 0, 1]
                                  ])
    end
  end

  describe "when mapping a point to the screen" do
    it "correctly maps points when the camera is at the origin" do
      camera = Engine::Components::OrthographicCamera.create(width: 10, height: 10, far: 10)
      Engine::GameObject.create(name: "Camera",
                             pos: Vector[0, 0, 0],
                             rotation: Vector[0, 0, 0],
                             scale: Vector[1, 1, 1],
                             components: [camera]
      )

      expect(Vector[0, 0, 0]).to be_on_screen_at(Vector[0, 0, -1])
      expect(Vector[0, 0, -10]).to be_on_screen_at(Vector[0, 0, 1])
      expect(Vector[5, 5, 0]).to be_on_screen_at(Vector[1, 1, -1])
      expect(Vector[-5, -5, 0]).to be_on_screen_at(Vector[-1, -1, -1])

      expect(Vector[0, 0, 1]).to be_on_screen_at(Vector[0, 0, -1.2])
      expect(Vector[0, 0, -11]).to be_on_screen_at(Vector[0, 0, 1.2])
      expect(Vector[6, 6, 0]).to be_on_screen_at(Vector[1.2, 1.2, -1])
      expect(Vector[-6, -6, 0]).to be_on_screen_at(Vector[-1.2, -1.2, -1])
    end

    it "correctly maps points when the camera is moved up" do
      camera = Engine::Components::OrthographicCamera.create(width: 10, height: 10, far: 10)
      Engine::GameObject.create(name: "Camera",
                             pos: Vector[0, 5, 0],
                             rotation: Vector[0, 0, 0],
                             scale: Vector[1, 1, 1],
                             components: [camera]
      )

      expect(Vector[0, 5, 0]).to be_on_screen_at(Vector[0, 0, -1])
      expect(Vector[0, 5, -10]).to be_on_screen_at(Vector[0, 0, 1])
      expect(Vector[5, 10, 0]).to be_on_screen_at(Vector[1, 1, -1])
      expect(Vector[-5, 0, 0]).to be_on_screen_at(Vector[-1, -1, -1])

      expect(Vector[0, 5, 1]).to be_on_screen_at(Vector[0, 0, -1.2])
      expect(Vector[0, 5, -11]).to be_on_screen_at(Vector[0, 0, 1.2])
      expect(Vector[6, 11, 0]).to be_on_screen_at(Vector[1.2, 1.2, -1])
      expect(Vector[-6, -1, 0]).to be_on_screen_at(Vector[-1.2, -1.2, -1])
    end

    it "correctly maps points when the camera is rotated" do
      camera = Engine::Components::OrthographicCamera.create(width: 10.0, height: 10.0, far: 10.0)
      Engine::GameObject.create(name: "Camera",
                             pos: Vector[0, 0, 0],
                             rotation: Vector[0, 90, 0],
                             scale: Vector[1, 1, 1],
                             components: [camera]
      )

      expect(Vector[0, 0, 0]).to be_on_screen_at(Vector[0, 0, -1])
      expect(Vector[10, 0, 0]).to be_on_screen_at(Vector[0, 0, 1])
      expect(Vector[0, 5, 5]).to be_on_screen_at(Vector[1, 1, -1])
      expect(Vector[0, -5, -5]).to be_on_screen_at(Vector[-1, -1, -1])

      expect(Vector[-1, 0, 0]).to be_on_screen_at(Vector[0, 0, -1.2])
      expect(Vector[11, 0, 0]).to be_on_screen_at(Vector[0, 0, 1.2])
      expect(Vector[0, 6, 6]).to be_on_screen_at(Vector[1.2, 1.2, -1])
      expect(Vector[0, -6, -6]).to be_on_screen_at(Vector[-1.2, -1.2, -1])
    end
  end
end