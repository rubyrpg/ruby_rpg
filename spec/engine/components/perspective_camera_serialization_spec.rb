# frozen_string_literal: true

describe Engine::Components::PerspectiveCamera do
  describe ".create" do
    it "creates a perspective camera with provided values" do
      camera = Engine::Components::PerspectiveCamera.create(
        fov: 45.0,
        aspect: 16.0 / 9.0,
        near: 0.1,
        far: 1000.0
      )

      expect(camera.instance_variable_get(:@fov)).to eq(45.0)
      expect(camera.instance_variable_get(:@aspect)).to eq(16.0 / 9.0)
      expect(camera.near).to eq(0.1)
      expect(camera.far).to eq(1000.0)
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Components::PerspectiveCamera.create(
        fov: 60.0,
        aspect: 4.0 / 3.0,
        near: 0.5,
        far: 500.0
      )

      serialized = Engine::Serialization::ObjectSerializer.serialize(original)
      restored = Engine::Serialization::ObjectSerializer.deserialize(serialized)
      restored.awake

      expect(restored.instance_variable_get(:@fov)).to eq(60.0)
      expect(restored.instance_variable_get(:@aspect)).to eq(4.0 / 3.0)
      expect(restored.near).to eq(0.5)
      expect(restored.far).to eq(500.0)
    end
  end
end
