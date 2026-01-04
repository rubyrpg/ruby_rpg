# frozen_string_literal: true

describe Engine::Physics::PhysicsResolver do
  describe '.resolve' do
    it "applies collision impulses to rigidbodies" do
      rigidbody = Engine::Physics::Components::Rigidbody.new
      collider = Engine::Physics::Components::SphereCollider.new(1)
      rigidbody_object = Engine::GameObject.create(components: [rigidbody, collider])

      other_rigidbody = Engine::Physics::Components::Rigidbody.new
      other_collider = Engine::Physics::Components::SphereCollider.new(1)
      other_rigidbody_object = Engine::GameObject.create(pos: Vector[1,0,0], components: [other_rigidbody, other_collider])

      expect(collider).to receive(:collision_for).with(other_collider).and_return(
        Engine::Physics::Collision.new(
          Vector[10, 0, 0],
          Vector[0, 0, 0]
        ))

      described_class.resolve
      rigidbody.update(0.1)

      expect(rigidbody.velocity).to be_vector(Vector[10, -0.981, 0])
    end
  end
end
