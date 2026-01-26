# frozen_string_literal: true

describe Engine::Components::UI::SpriteClickbox do
  context "when there is no UI::Rect" do
    let(:game_object) do
      Engine::GameObject.create(name: "Test",
                                components: [Engine::Components::UI::SpriteClickbox.create])
    end

    it "raises an error" do
      expect { game_object.components.first.start }
        .to raise_error("UI::SpriteClickbox requires a UI::Rect component")
    end
  end

  context "when clicking a sprite" do
    before do
      allow_any_instance_of(Engine::Components::UI::SpriteRenderer).to receive(:start)
      allow(Engine::Window).to receive(:framebuffer_width).and_return(800)
      allow(Engine::Window).to receive(:framebuffer_height).and_return(600)
      allow(Engine::Window).to receive(:height).and_return(600)
    end

    let(:game_object) do
      Engine::GameObject.create(name: "Test",
                                components: [
                                  Engine::Components::UI::Rect.create(
                                    left_ratio: 0.0,
                                    right_ratio: 0.5,
                                    bottom_ratio: 0.0,
                                    top_ratio: 0.5
                                  ),
                                  Engine::Components::UI::SpriteRenderer.create(material: nil),
                                  Engine::Components::UI::SpriteClickbox.create
                                ])
    end

    let(:clickbox) { game_object.components.find { |c| c.is_a? Engine::Components::UI::SpriteClickbox } }
    let(:ui_rect) { game_object.components.find { |c| c.is_a? Engine::Components::UI::Rect } }

    before do
      ui_rect.awake
      clickbox.start
    end

    it "clicks the sprite" do
      # Initial state - no mouse position yet
      clickbox.update(0)
      expect(clickbox.clicked).to be false
      expect(clickbox.mouse_inside).to be false
      expect(clickbox.mouse_entered).to be false
      expect(clickbox.mouse_exited).to be false

      # Y-down: rect is 0-400 x, 300-600 y (top=300, bottom=600)
      Engine::Input.mouse_callback(200, 450)  # 450 is inside 300-600
      clickbox.update(0)
      expect(clickbox.clicked).to be false
      expect(clickbox.mouse_inside).to be true
      expect(clickbox.mouse_entered).to be true
      expect(clickbox.mouse_exited).to be false

      # Click while inside
      Engine::Input.mouse_callback(200, 450)
      Engine::Input.mouse_button_callback(Engine::Input::MOUSE_BUTTON_LEFT, Engine::Input::PRESS)
      clickbox.update(0)
      expect(clickbox.clicked).to be true
      expect(clickbox.mouse_inside).to be true
      expect(clickbox.mouse_entered).to be false
      expect(clickbox.mouse_exited).to be false

      # Release click
      Engine::Input.mouse_callback(200, 450)
      Engine::Input.mouse_button_callback(Engine::Input::MOUSE_BUTTON_LEFT, Engine::Input::RELEASE)
      clickbox.update(0)
      expect(clickbox.clicked).to be false
      expect(clickbox.mouse_inside).to be true
      expect(clickbox.mouse_entered).to be false
      expect(clickbox.mouse_exited).to be false

      # Move mouse outside
      Engine::Input.mouse_callback(500, 100)  # outside the 0-400 x range
      clickbox.update(0)
      expect(clickbox.clicked).to be false
      expect(clickbox.mouse_inside).to be false
      expect(clickbox.mouse_entered).to be false
      expect(clickbox.mouse_exited).to be true
    end
  end
end
