# frozen_string_literal: true

describe Engine::Components::UISpriteClickbox do
  context "when there is no sprite renderer" do
    let (:game_object) do
      Engine::GameObject.create(name: "Test",
                             components: [Engine::Components::UISpriteClickbox.create]
      )
    end

    it "raises an error" do
      expect { game_object.components.first.start }
        .to raise_error("UISpriteClickbox requires a UISpriteRenderer")
    end
  end

  context "when clicking a sprite" do
    before do
      allow_any_instance_of(Engine::Components::UISpriteRenderer).to receive(:start)
    end

    let(:game_object) do
      Engine::GameObject.create(name: "Test",
                             components: [
                               Engine::Components::UISpriteRenderer.create(
                                 v1: Vector[-100, 50],
                                 v2: Vector[50, 50],
                                 v3: Vector[50, -50],
                                 v4: Vector[-50, -50],
                                 material: nil
                               ),
                               Engine::Components::UISpriteClickbox.create
                             ]
      )
    end

    let(:clickbox) { game_object.components.find { |c| c.is_a? Engine::Components::UISpriteClickbox } }

    it "clicks the sprite" do
      clickbox.start
      clickbox.update(0)
      expect(clickbox.clicked).to be false
      expect(clickbox.mouse_inside).to be false
      expect(clickbox.mouse_entered).to be false
      expect(clickbox.mouse_exited).to be false

      Engine::Input.mouse_callback(0, Engine::Window.height)
      clickbox.update(0)
      expect(clickbox.clicked).to be false
      expect(clickbox.mouse_inside).to be true
      expect(clickbox.mouse_entered).to be true
      expect(clickbox.mouse_exited).to be false

      Engine::Input.mouse_callback(0, Engine::Window.height)
      Engine::Input.mouse_button_callback(GLFW::MOUSE_BUTTON_LEFT, GLFW::PRESS)
      clickbox.update(0)
      expect(clickbox.clicked).to be true
      expect(clickbox.mouse_inside).to be true
      expect(clickbox.mouse_entered).to be false
      expect(clickbox.mouse_exited).to be false

      Engine::Input.mouse_callback(0, Engine::Window.height)
      Engine::Input.mouse_button_callback(GLFW::MOUSE_BUTTON_LEFT, GLFW::RELEASE)
      clickbox.update(0)
      expect(clickbox.clicked).to be false
      expect(clickbox.mouse_inside).to be true
      expect(clickbox.mouse_entered).to be false
      expect(clickbox.mouse_exited).to be false

      Engine::Input.mouse_callback(100, Engine::Window.height - 100)
      clickbox.update(0)
      expect(clickbox.clicked).to be false
      expect(clickbox.mouse_inside).to be false
      expect(clickbox.mouse_entered).to be false
      expect(clickbox.mouse_exited).to be true
    end
  end
end
