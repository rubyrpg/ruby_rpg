# frozen_string_literal: true

describe Engine::Components::PointLight do
  describe ".create" do
    it "creates a point light with default values" do
      light = Engine::Components::PointLight.create

      expect(light.range).to eq(300)
      expect(light.colour).to eq([1.0, 1.0, 1.0])
      expect(light.cast_shadows).to eq(false)
    end

    it "creates a point light with custom values" do
      light = Engine::Components::PointLight.create(
        range: 500,
        colour: [0.8, 0.6, 0.4],
        cast_shadows: true
      )

      expect(light.range).to eq(500)
      expect(light.colour).to eq([0.8, 0.6, 0.4])
      expect(light.cast_shadows).to eq(true)
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Components::PointLight.create(
        range: 500,
        colour: [0.8, 0.6, 0.4],
        cast_shadows: true
      )

      serialized = Engine::Serialization::ObjectSerializer.serialize(original)
      restored = Engine::Serialization::ObjectSerializer.deserialize(serialized)
      restored.awake

      expect(restored.range).to eq(500)
      expect(restored.colour).to eq([0.8, 0.6, 0.4])
      expect(restored.cast_shadows).to eq(true)
    end
  end
end
