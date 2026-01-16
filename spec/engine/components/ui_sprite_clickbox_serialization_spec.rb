# frozen_string_literal: true

describe Engine::Components::UISpriteClickbox do
  describe ".create" do
    it "creates a clickbox with default values" do
      clickbox = Engine::Components::UISpriteClickbox.create

      expect(clickbox.mouse_inside).to eq(false)
      expect(clickbox.clicked).to eq(false)
      expect(clickbox.mouse_entered).to eq(false)
      expect(clickbox.mouse_exited).to eq(false)
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Components::UISpriteClickbox.create

      serialized = Engine::Serialization::ObjectSerializer.serialize(original)
      restored = Engine::Serialization::ObjectSerializer.deserialize(serialized)
      restored.awake

      expect(restored.mouse_inside).to eq(false)
      expect(restored.clicked).to eq(false)
      expect(restored.mouse_entered).to eq(false)
      expect(restored.mouse_exited).to eq(false)
    end
  end
end
