# frozen_string_literal: true

describe "two spheres colliding" do
  let(:angular_momentum_origin) { Vector[100, 100, 100] }

  context "with two dynamic spheres" do
    context "when one sphere runs into a stationary sphere" do
      let(:object_1) do
        Engine::GameObject.create(
          name: "object_1",
          pos: Vector[0, 0, 0],
          components: [
            Engine::Physics::Components::SphereCollider.create(radius: 1.01),
            Engine::Physics::Components::Rigidbody.create(
              velocity: Vector[10, 0, 0],
              gravity: Vector[0, 0, 0],
              mass: mass_1
            )
          ]
        )
      end
      let(:mass_1) { 1 }
      let(:rigidbody_1) { object_1.components.find { |c| c.is_a?(Engine::Physics::Components::Rigidbody) } }
      let(:object_2) do
        Engine::GameObject.create(
          name: "object_2",
          pos: Vector[2, 0, 0],
          components: [
            Engine::Physics::Components::SphereCollider.create(radius: 1.01),
            Engine::Physics::Components::Rigidbody.create(
              velocity: Vector[0, 0, 0],
              gravity: Vector[0, 0, 0],
              mass: mass_2
            )
          ]
        )
      end
      let(:mass_2) { 1 }
      let(:rigidbody_2) { object_2.components.find { |c| c.is_a?(Engine::Physics::Components::Rigidbody) } }

      it "conserves momentum and energy" do
        starting_kinetic_energy = rigidbody_1.kinetic_energy + rigidbody_2.kinetic_energy
        starting_momentum = rigidbody_1.momentum + rigidbody_2.momentum
        starting_angular_momentum = rigidbody_1.angular_momentum(angular_momentum_origin) + rigidbody_2.angular_momentum(angular_momentum_origin)

        Engine::Physics::PhysicsResolver.resolve
        object_1.components.each { |c| c.update(0.1) }
        object_2.components.each { |c| c.update(0.1) }

        expect(rigidbody_1.kinetic_energy + rigidbody_2.kinetic_energy).to eq(starting_kinetic_energy)
        expect(rigidbody_1.momentum + rigidbody_2.momentum).to eq(starting_momentum)
        expect(rigidbody_1.angular_momentum(angular_momentum_origin) + rigidbody_2.angular_momentum(angular_momentum_origin)).to eq(starting_angular_momentum)

        expect(rigidbody_1.velocity).to eq(Vector[0, 0, 0])
        expect(rigidbody_2.velocity).to eq(Vector[10, 0, 0])
      end

      context "with different masses" do
        let(:mass_1) { 2 }
        let(:mass_2) { 1 }

        it "conserves momentum and energy" do
          starting_kinetic_energy = rigidbody_1.kinetic_energy + rigidbody_2.kinetic_energy
          starting_momentum = rigidbody_1.momentum + rigidbody_2.momentum
          starting_angular_momentum = rigidbody_1.angular_momentum(angular_momentum_origin) + rigidbody_2.angular_momentum(angular_momentum_origin)

          Engine::Physics::PhysicsResolver.resolve
          object_1.components.each { |c| c.update(0.1) }
          object_2.components.each { |c| c.update(0.1) }

          expect(rigidbody_1.kinetic_energy + rigidbody_2.kinetic_energy).to be_within(0.00001).of(starting_kinetic_energy)
          expect(rigidbody_1.momentum + rigidbody_2.momentum).to eq(starting_momentum)
          expect(rigidbody_1.angular_momentum(angular_momentum_origin) + rigidbody_2.angular_momentum(angular_momentum_origin)).to eq(starting_angular_momentum)
          expect(rigidbody_1.velocity).to be_vector(Vector[3.3333333, 0, 0])
          expect(rigidbody_2.velocity).to be_vector(Vector[13.3333333, 0, 0])
        end
      end
    end

    context "when two spheres collide head-on" do
      let(:object_1) do
        Engine::GameObject.create(
          name: "object_1",
          pos: Vector[0, 0, 0],
          components: [
            Engine::Physics::Components::SphereCollider.create(radius: 1.01),
            Engine::Physics::Components::Rigidbody.create(
              velocity: Vector[10, 0, 0],
              gravity: Vector[0, 0, 0]
            )
          ]
        )
      end
      let(:rigidbody_1) { object_1.components.find { |c| c.is_a?(Engine::Physics::Components::Rigidbody) } }
      let(:object_2) do
        Engine::GameObject.create(
          name: "object_2",
          pos: Vector[2, 0, 0],
          components: [
            Engine::Physics::Components::SphereCollider.create(radius: 1.01),
            Engine::Physics::Components::Rigidbody.create(
              velocity: Vector[-10, 0, 0],
              gravity: Vector[0, 0, 0]
            )
          ]
        )
      end
      let(:rigidbody_2) { object_2.components.find { |c| c.is_a?(Engine::Physics::Components::Rigidbody) } }

      it "conserves momentum and energy" do
        starting_kinetic_energy = rigidbody_1.kinetic_energy + rigidbody_2.kinetic_energy
        starting_momentum = rigidbody_1.momentum + rigidbody_2.momentum
        starting_angular_momentum = rigidbody_1.angular_momentum(angular_momentum_origin) + rigidbody_2.angular_momentum(angular_momentum_origin)

        Engine::Physics::PhysicsResolver.resolve
        object_1.components.each { |c| c.update(0.1) }
        object_2.components.each { |c| c.update(0.1) }

        expect(rigidbody_1.kinetic_energy + rigidbody_2.kinetic_energy).to eq(starting_kinetic_energy)
        expect(rigidbody_1.momentum + rigidbody_2.momentum).to eq(starting_momentum)
        expect(rigidbody_1.angular_momentum(angular_momentum_origin) + rigidbody_2.angular_momentum(angular_momentum_origin)).to eq(starting_angular_momentum)
        expect(rigidbody_1.velocity).to eq(Vector[-10, 0, 0])
        expect(rigidbody_2.velocity).to eq(Vector[10, 0, 0])
      end
    end

    context "when two spheres collide at an angle" do
      let(:object_1) do
        Engine::GameObject.create(
          name: "object_1",
          pos: Vector[0, 0, 0],
          components: [
            Engine::Physics::Components::SphereCollider.create(radius: 1.01),
            Engine::Physics::Components::Rigidbody.create(
              velocity: Vector[10, 10, 0],
              gravity: Vector[0, 0, 0]
            )
          ]
        )
      end
      let(:rigidbody_1) { object_1.components.find { |c| c.is_a?(Engine::Physics::Components::Rigidbody) } }
      let(:object_2) do
        Engine::GameObject.create(
          name: "object_2",
          pos: Vector[2, 0, 0],
          components: [
            Engine::Physics::Components::SphereCollider.create(radius: 1.01),
            Engine::Physics::Components::Rigidbody.create(
              velocity: Vector[-10, 10, 0],
              gravity: Vector[0, 0, 0]
            )
          ]
        )
      end
      let(:rigidbody_2) { object_2.components.find { |c| c.is_a?(Engine::Physics::Components::Rigidbody) } }

      it "conserves momentum and energy" do
        starting_kinetic_energy = rigidbody_1.kinetic_energy + rigidbody_2.kinetic_energy
        starting_momentum = rigidbody_1.momentum + rigidbody_2.momentum
        starting_angular_momentum = rigidbody_1.angular_momentum(angular_momentum_origin) + rigidbody_2.angular_momentum(angular_momentum_origin)

        Engine::Physics::PhysicsResolver.resolve
        object_1.components.each { |c| c.update(0.1) }
        object_2.components.each { |c| c.update(0.1) }

        expect(rigidbody_1.kinetic_energy + rigidbody_2.kinetic_energy).to eq(starting_kinetic_energy)
        expect(rigidbody_1.momentum + rigidbody_2.momentum).to eq(starting_momentum)
        expect(rigidbody_1.angular_momentum(angular_momentum_origin) + rigidbody_2.angular_momentum(angular_momentum_origin)).to eq(starting_angular_momentum)
        expect(rigidbody_1.velocity).to eq(Vector[-10, 10, 0])
        expect(rigidbody_2.velocity).to eq(Vector[10, 10, 0])
      end
    end

    context "when two spheres collide with a head on glancing blow" do
      let(:object_1) do
        Engine::GameObject.create(
          name: "object_1",
          pos: Vector[0, 0, 0],
          components: [
            Engine::Physics::Components::SphereCollider.create(radius: 1.01),
            Engine::Physics::Components::Rigidbody.create(
              velocity: Vector[1, 10, 0],
              gravity: Vector[0, 0, 0]
            )
          ]
        )
      end
      let(:rigidbody_1) { object_1.components.find { |c| c.is_a?(Engine::Physics::Components::Rigidbody) } }
      let(:object_2) do
        Engine::GameObject.create(
          name: "object_2",
          pos: Vector[2, 0, 0],
          components: [
            Engine::Physics::Components::SphereCollider.create(radius: 1.01),
            Engine::Physics::Components::Rigidbody.create(
              velocity: Vector[-1, -10, 0],
              gravity: Vector[0, 0, 0]
            )
          ]
        )
      end
      let(:rigidbody_2) { object_2.components.find { |c| c.is_a?(Engine::Physics::Components::Rigidbody) } }

      it "conserves momentum and energy" do
        starting_kinetic_energy = rigidbody_1.kinetic_energy + rigidbody_2.kinetic_energy
        starting_momentum = rigidbody_1.momentum + rigidbody_2.momentum
        starting_angular_momentum = rigidbody_1.angular_momentum(angular_momentum_origin) + rigidbody_2.angular_momentum(angular_momentum_origin)

        Engine::Physics::PhysicsResolver.resolve
        object_1.components.each { |c| c.update(0.1) }
        object_2.components.each { |c| c.update(0.1) }

        expect(rigidbody_1.kinetic_energy + rigidbody_2.kinetic_energy).to eq(starting_kinetic_energy)
        expect(rigidbody_1.momentum + rigidbody_2.momentum).to eq(starting_momentum)
        expect(rigidbody_1.angular_momentum(angular_momentum_origin) + rigidbody_2.angular_momentum(angular_momentum_origin)).to eq(starting_angular_momentum)
        expect(rigidbody_1.velocity).to eq(Vector[-1, 10, 0])
        expect(rigidbody_2.velocity).to eq(Vector[1, -10, 0])
      end
    end
  end

  context "with a dynamic sphere and a static sphere" do
    context "when a dynamic sphere hits a stationary sphere" do
      let!(:object_1) do
        Engine::GameObject.create(
          name: "object_1",
          pos: Vector[0, 0, 0],
          components: [
            Engine::Physics::Components::SphereCollider.create(radius: 1.01),
            Engine::Physics::Components::Rigidbody.create(
              velocity: Vector[10, 0, 0],
              gravity: Vector[0, 0, 0]
            )
          ]
        )
      end
      let(:rigidbody_1) { object_1.components.find { |c| c.is_a?(Engine::Physics::Components::Rigidbody) } }
      let!(:object_2) do
        Engine::GameObject.create(
          name: "object_2",
          pos: Vector[2, 0, 0],
          components: [
            Engine::Physics::Components::SphereCollider.create(radius: 1.01)
          ]
        )
      end

      it "conserves energy but not momentum" do
        starting_kinetic_energy = rigidbody_1.kinetic_energy
        starting_momentum = rigidbody_1.momentum

        Engine::Physics::PhysicsResolver.resolve
        object_1.components.each { |c| c.update(0.1) }

        expect(rigidbody_1.kinetic_energy).to eq(starting_kinetic_energy)
        #expect(rigidbody_1.momentum).not_to eq(starting_momentum)
        expect(rigidbody_1.velocity).to eq(Vector[-10, 0, 0])
      end
    end
  end
end
