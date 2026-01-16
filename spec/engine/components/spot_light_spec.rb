# frozen_string_literal: true

describe Engine::Components::SpotLight do
  describe ".create" do
    it "creates a spot light with default values" do
      light = Engine::Components::SpotLight.create

      expect(light.range).to eq(300)
      expect(light.colour).to eq([1.0, 1.0, 1.0])
      expect(light.inner_angle).to eq(12.5)
      expect(light.outer_angle).to eq(17.5)
      expect(light.cast_shadows).to eq(false)
    end

    it "creates a spot light with custom values" do
      light = Engine::Components::SpotLight.create(
        range: 500,
        colour: [0.8, 0.6, 0.4],
        inner_angle: 20.0,
        outer_angle: 30.0,
        cast_shadows: true
      )

      expect(light.range).to eq(500)
      expect(light.colour).to eq([0.8, 0.6, 0.4])
      expect(light.inner_angle).to eq(20.0)
      expect(light.outer_angle).to eq(30.0)
      expect(light.cast_shadows).to eq(true)
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Components::SpotLight.create(
        range: 500,
        colour: [0.8, 0.6, 0.4],
        inner_angle: 20.0,
        outer_angle: 30.0,
        cast_shadows: true
      )

      serialized = Engine::Serialization::ObjectSerializer.serialize(original)
      restored = Engine::Serialization::ObjectSerializer.deserialize(serialized)
      restored.awake

      expect(restored.range).to eq(500)
      expect(restored.colour).to eq([0.8, 0.6, 0.4])
      expect(restored.inner_angle).to eq(20.0)
      expect(restored.outer_angle).to eq(30.0)
      expect(restored.cast_shadows).to eq(true)
    end
  end
end
