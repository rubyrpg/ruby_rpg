# frozen_string_literal: true

describe Engine::Physics::Components::Rigidbody do
  describe ".create" do
    it "creates a rigidbody with default values" do
      rb = Engine::Physics::Components::Rigidbody.create

      expect(rb.velocity).to eq(Vector[0, 0, 0])
      expect(rb.angular_velocity).to eq(Vector[0, 0, 0])
      expect(rb.mass).to eq(1)
      expect(rb.coefficient_of_restitution).to eq(1)
      expect(rb.coefficient_of_friction).to eq(0)
    end

    it "creates a rigidbody with custom values" do
      rb = Engine::Physics::Components::Rigidbody.create(
        velocity: Vector[1, 2, 3],
        mass: 5,
        gravity: Vector[0, -10, 0],
        coefficient_of_restitution: 0.8
      )

      expect(rb.velocity).to eq(Vector[1, 2, 3])
      expect(rb.mass).to eq(5)
      expect(rb.coefficient_of_restitution).to eq(0.8)
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Physics::Components::Rigidbody.create(
        velocity: Vector[1, 2, 3],
        angular_velocity: Vector[0.1, 0.2, 0.3],
        mass: 5,
        coefficient_of_restitution: 0.8,
        coefficient_of_friction: 0.5
      )

      serialized = Engine::Serialization::ObjectSerializer.serialize(original)
      restored = Engine::Serialization::ObjectSerializer.deserialize(serialized)
      restored.awake

      expect(restored.velocity).to eq(Vector[1, 2, 3])
      expect(restored.angular_velocity).to eq(Vector[0.1, 0.2, 0.3])
      expect(restored.mass).to eq(5)
      expect(restored.coefficient_of_restitution).to eq(0.8)
      expect(restored.coefficient_of_friction).to eq(0.5)
    end
  end
end
