# frozen_string_literal: true

describe Engine::Components::SpriteAnimator do
  let(:material) { double("material") }

  describe ".create" do
    it "creates a sprite animator with default values" do
      animator = Engine::Components::SpriteAnimator.create(
        material: material,
        frame_coords: [{ tl: [0, 0], width: 0.5, height: 0.5 }]
      )

      expect(animator.frame_rate).to eq(1)
      expect(animator.loop).to eq(true)
    end

    it "creates a sprite animator with custom values" do
      animator = Engine::Components::SpriteAnimator.create(
        material: material,
        frame_coords: [{ tl: [0, 0], width: 0.5, height: 0.5 }],
        frame_rate: 10,
        loop: false
      )

      expect(animator.frame_rate).to eq(10)
      expect(animator.loop).to eq(false)
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Components::SpriteAnimator.create(
        material: nil,
        frame_coords: [
          { tl: [0, 0], width: 0.5, height: 0.5 },
          { tl: [0.5, 0], width: 0.5, height: 0.5 }
        ],
        frame_rate: 15,
        loop: false
      )

      serialized = Engine::Serialization::ObjectSerializer.serialize(original)
      restored = Engine::Serialization::ObjectSerializer.deserialize(serialized)
      restored.awake

      expect(restored.frame_rate).to eq(15)
      expect(restored.loop).to eq(false)
    end
  end
end
