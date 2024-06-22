# frozen_string_literal: true

describe Engine::Physics::Components::SphereCollider do
  describe '#collision_for' do
    context 'when colliding with another sphere' do
      let(:collider) { described_class.new(radius) }
      let!(:collider_object) do
        Engine::GameObject.new(
          "collider_object",
          pos: position,
          components: [
            collider,
            Engine::Physics::Components::Rigidbody.new(velocity: velocity)
          ]
        )
      end
      let(:velocity) { Vector[0, 0, 0] }

      let(:other_collider) { described_class.new(other_radius) }
      let!(:other_collider_object) do
        Engine::GameObject.new(
          "other_collider_object",
          pos: other_position,
          components: [
            other_collider,
            Engine::Physics::Components::Rigidbody.new(velocity: other_velocity)
          ]
        )
      end
      let(:other_velocity) { Vector[0, 0, 0] }

      context "when the spheres are touching" do
        let(:position) { Vector[0, 0, 0] }
        let(:other_position) { Vector[2, 0, 0] }
        let(:radius) { 1.51 }
        let(:other_radius) { 0.51 }

        it 'returns a collision' do
          collision = collider.collision_for(other_collider)

          expect(collision.point).to eq(Vector[1.5, 0, 0])
          expect(collision.impulse).to eq(Vector[0, 0, 0])
        end
      end

      context "when the spheres are moving towards each other" do
        let(:position) { Vector[0, 0, 0] }
        let(:other_position) { Vector[2, 0, 0] }
        let(:radius) { 1.51 }
        let(:other_radius) { 0.51 }
        let(:velocity) { Vector[1, 0, 0] }

        it 'returns a collision' do
          collision = collider.collision_for(other_collider)

          expect(collision.point).to eq(Vector[1.5, 0, 0])
          expect(collision.impulse).to eq(Vector[-1, 0, 0])
        end
      end

      context "when the spheres are moving away from each other" do
        let(:position) { Vector[0, 0, 0] }
        let(:other_position) { Vector[2, 0, 0] }
        let(:radius) { 1.51 }
        let(:other_radius) { 0.51 }
        let(:velocity) { Vector[-1, 0, 0] }

        it 'returns nil' do
          collision = collider.collision_for(other_collider)

          expect(collision).to be_nil
        end
      end
    end
  end
end
