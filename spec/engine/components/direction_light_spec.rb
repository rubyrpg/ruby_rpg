# frozen_string_literal: true

describe Engine::Components::DirectionLight do
  describe ".create" do
    it "creates a direction light with default values" do
      light = Engine::Components::DirectionLight.create

      expect(light.colour).to eq([1.0, 1.0, 1.0])
      expect(light.cast_shadows).to eq(true)
      expect(light.shadow_distance).to eq(50.0)
    end

    it "creates a direction light with custom values" do
      light = Engine::Components::DirectionLight.create(
        colour: [0.5, 0.5, 0.5],
        cast_shadows: false,
        shadow_distance: 200.0
      )

      expect(light.colour).to eq([0.5, 0.5, 0.5])
      expect(light.cast_shadows).to eq(false)
      expect(light.shadow_distance).to eq(200.0)
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Components::DirectionLight.create(
        colour: [0.8, 0.9, 1.0],
        cast_shadows: true,
        shadow_distance: 100.0
      )

      serialized = original.to_serialized
      restored = Engine::Serializable.from_serialized(serialized)
      restored.awake

      expect(restored.colour).to eq([0.8, 0.9, 1.0])
      expect(restored.cast_shadows).to eq(true)
      expect(restored.shadow_distance).to eq(100.0)
    end
  end
end
