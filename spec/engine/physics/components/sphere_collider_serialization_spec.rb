# frozen_string_literal: true

describe Engine::Physics::Components::SphereCollider do
  describe ".create" do
    it "creates a sphere collider with default values" do
      collider = Engine::Physics::Components::SphereCollider.create

      expect(collider.radius).to eq(1)
    end

    it "creates a sphere collider with custom values" do
      collider = Engine::Physics::Components::SphereCollider.create(radius: 5)

      expect(collider.radius).to eq(5)
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Physics::Components::SphereCollider.create(radius: 3.5)

      serialized = original.to_serialized
      restored = Engine::Serializable.from_serialized(serialized)
      restored.awake

      expect(restored.radius).to eq(3.5)
    end
  end
end
