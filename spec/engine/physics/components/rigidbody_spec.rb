# frozen_string_literal: true

describe Engine::Physics::Components::Rigidbody do
  describe '#update' do
    let(:rigidbody) do
      described_class.new(
        velocity:,
        angular_velocity:,
        gravity:,
        mass:
      )
    end
    let(:angular_velocity) { Vector[0, 0, 0] }
    let!(:rigidbody_object) do
      Engine::GameObject.new(
        "rigidbody_object",
        components: [rigidbody]
      )
    end

    context "with no velocity or gravity" do
      let(:velocity) { Vector[0, 0, 0] }
      let(:gravity) { Vector[0, 0, 0] }
      let(:mass) { 1 }

      it 'is stationary' do
        rigidbody.update(0.1)

        expect(rigidbody_object.pos).to eq(Vector[0, 0, 0])
        expect(rigidbody.velocity).to eq(Vector[0, 0, 0])
      end
    end

    context "with some velocity" do
      let(:velocity) { Vector[1, 0, 0] }
      let(:gravity) { Vector[0, 0, 0] }
      let(:mass) { 1 }

      it 'moves' do
        rigidbody.update(0.1)

        expect(rigidbody_object.pos).to eq(Vector[0.1, 0, 0])
        expect(rigidbody.velocity).to eq(Vector[1, 0, 0])

        rigidbody.update(0.1)

        expect(rigidbody_object.pos).to eq(Vector[0.2, 0, 0])
        expect(rigidbody.velocity).to eq(Vector[1, 0, 0])
      end
    end

    context "with some gravity" do
      let(:velocity) { Vector[0, 0, 0] }
      let(:gravity) { Vector[0, -9.81, 0] }
      let(:mass) { 1 }

      it 'falls' do
        rigidbody.update(0.1)

        expect(rigidbody_object.pos).to be_vector(Vector[0, -0.0981, 0])
        expect(rigidbody.velocity).to be_vector(Vector[0, -0.981, 0])

        rigidbody.update(0.1)

        expect(rigidbody_object.pos).to be_vector(Vector[0, -0.2943, 0])
        expect(rigidbody.velocity).to be_vector(Vector[0, -1.962, 0])
      end
    end

    context "with some angular velocity" do
      let(:angular_velocity) { Vector[1, 0, 0] }
      let(:velocity) { Vector[0, 0, 0] }
      let(:gravity) { Vector[0, 0, 0] }
      let(:mass) { 1 }

      it 'rotates' do
        rigidbody.update(0.1)

        expect(rigidbody_object.pos).to eq(Vector[0, 0, 0])
        expect(rigidbody_object.rotation.to_euler).to be_vector(Vector[0.1, 0, 0])
      end
    end

    context "when applying an impulse" do
      let(:velocity) { Vector[0, 5, 0] }
      let(:gravity) { Vector[0, -9.81, 0] }
      let(:mass) { 1 }
      let(:impulse) { Vector[1, 0, 0] }

      context "directly to the object" do
        it 'instantly changes velocity' do
          rigidbody.apply_impulse(impulse, rigidbody_object.pos)
          rigidbody.update(0.1)

          expect(rigidbody_object.pos).to be_vector(Vector[0.1, 0.4019, 0])
          expect(rigidbody.velocity).to be_vector(Vector[1, 4.019, 0])
          expect(rigidbody.angular_velocity).to be_vector(Vector[0, 0, 0])

          rigidbody.update(0.1)

          expect(rigidbody_object.pos).to be_vector(Vector[0.2, 0.7057, 0])
          expect(rigidbody.velocity).to be_vector(Vector[1, 3.038, 0])
          expect(rigidbody.angular_velocity).to be_vector(Vector[0, 0, 0])
        end
      end

      context "to a point on the object" do
        it 'instantly changes velocity and angular velocity' do
          rigidbody.apply_impulse(impulse, rigidbody_object.pos + Vector[0, 1, 0])
          rigidbody.update(0.1)

          expect(rigidbody_object.pos).to be_vector(Vector[0.1, 0.4019, 0])
          expect(rigidbody.velocity).to be_vector(Vector[1, 4.019, 0])
          expect(rigidbody.angular_velocity).to be_vector(Vector[0, 0, 1])

          rigidbody.update(0.1)

          expect(rigidbody_object.pos).to be_vector(Vector[0.2, 0.7057, 0])
          expect(rigidbody.velocity).to be_vector(Vector[1, 3.038, 0])
          expect(rigidbody.angular_velocity).to be_vector(Vector[0, 0, 1])
        end
      end
    end

    context "when applying an angular impulse" do
      context "to a stationary object" do
        let(:velocity) { Vector[0, 0, 0] }
        let(:angular_velocity) { Vector[0, 0, 0] }
        let(:gravity) { Vector[0, 0, 0] }
        let(:mass) { 1 }
        let(:impulse) { Vector[1, 0, 0] }

        it 'instantly changes angular velocity' do
          rigidbody.apply_angular_impulse(impulse)
          rigidbody.update(0.1)

          expect(rigidbody_object.pos).to eq(Vector[0, 0, 0])
          expect(rigidbody_object.rotation.to_euler).to be_vector(Vector[0.1, 0, 0])
          expect(rigidbody.angular_velocity).to eq(Vector[1, 0, 0])

          rigidbody.update(0.1)

          expect(rigidbody_object.pos).to eq(Vector[0, 0, 0])
          expect(rigidbody_object.rotation.to_euler).to be_vector(Vector[0.2, 0, 0])
          expect(rigidbody.angular_velocity).to eq(Vector[1, 0, 0])
        end
      end

      context "to a rotating object" do
        let(:velocity) { Vector[0, 0, 0] }
        let(:angular_velocity) { Vector[0, 5, 0] }
        let(:gravity) { Vector[0, 0, 0] }
        let(:mass) { 1 }
        let(:impulse) { Vector[1, 0, 0] }

        it 'instantly changes angular velocity' do
          rigidbody.apply_angular_impulse(impulse)
          rigidbody.update(0.1)

          expect(rigidbody_object.pos).to eq(Vector[0, 0, 0])
          expect(rigidbody_object.rotation.to_euler).to be_vector(Vector[0.1, 0.5, 0], tolerance: 0.001) # angle axis introduces a small error here
          expect(rigidbody.angular_velocity).to eq(Vector[1, 5, 0])

          rigidbody.update(0.1)

          expect(rigidbody_object.pos).to eq(Vector[0, 0, 0])
          expect(rigidbody_object.rotation.to_euler).to be_vector(Vector[0.2, 1, 0], tolerance: 0.01) # angle axis introduces a small error here
          expect(rigidbody.angular_velocity).to eq(Vector[1, 5, 0])
        end
      end
    end
  end

  describe "#kinetic_energy" do
    context "for a stationary object" do
      let(:rigidbody) do
        described_class.new(
          velocity: Vector[0, 0, 0],
          angular_velocity: Vector[0, 0, 0],
          gravity: Vector[0, 0, 0],
          mass: 1
        )
      end

      it "is zero" do
        expect(rigidbody.kinetic_energy).to eq(0)
      end
    end

    context "for a moving object" do
      let(:rigidbody) do
        described_class.new(
          velocity: Vector[5, 0, 0],
          angular_velocity: Vector[0, 0, 0],
          gravity: Vector[0, 0, 0],
          mass: 2
        )
      end

      it "is 25" do
        expect(rigidbody.kinetic_energy).to eq(25)
      end
    end

    context "for a rotating object" do
      let(:rigidbody) do
        described_class.new(
          velocity: Vector[0, 0, 0],
          angular_velocity: Vector[0, 5, 0],
          gravity: Vector[0, 0, 0],
          mass: 1
        )
      end

      it "is 12.5" do
        expect(rigidbody.kinetic_energy).to eq(12.5)
      end
    end

    context "for a rotating body with a non-standard inertia tensor" do
      let(:rigidbody) do
        described_class.new(
          velocity: Vector[0, 0, 0],
          angular_velocity: Vector[0, 5, 0],
          gravity: Vector[0, 0, 0],
          mass: 324,
          inertia_tensor: Matrix[
            [1, 0, 0],
            [0, 2, 0],
            [0, 0, 3]
          ]
        )
      end

      it "is 25" do
        expect(rigidbody.kinetic_energy).to eq(25)
      end
    end

    context "for a moving and rotating object" do
      let(:rigidbody) do
        described_class.new(
          velocity: Vector[5, 0, 0],
          angular_velocity: Vector[0, 5, 0],
          gravity: Vector[0, 0, 0],
          mass: 2
        )
      end

      it "is 50" do
        expect(rigidbody.kinetic_energy).to eq(50)
      end
    end
  end

  describe "#momenturn" do
    let(:rigidbody) do
      described_class.new(
        velocity: Vector[5, 0, 0],
        angular_velocity: Vector[0, 5, 0],
        gravity: Vector[0, 0, 0],
        mass: 2
      )
    end

    it "is 10 kg m/s in the direction of motion" do
      expect(rigidbody.momentum).to eq(Vector[10, 0, 0])
    end
  end

  describe "#angular_momentum" do
    let!(:rigidbody_object) do
      Engine::GameObject.new(
        "rigidbody_object",
        pos:,
        components: [rigidbody]
      )
    end
    let(:rigidbody) do
      described_class.new(
        velocity:,
        angular_velocity:,
        gravity: Vector[0, 0, 0],
        mass:
      )
    end

    context "when the object is spinning" do
      let(:pos) { Vector[0, 0, 0] }
      let(:velocity) { Vector[0, 0, 0] }
      let(:angular_velocity) { Vector[0, 5, 0] }
      let(:mass) { 2 }

      it "is 10 kg m^2/s in the direction of rotation" do
        expect(rigidbody.angular_momentum).to eq(Vector[0, 10, 0])
      end
    end

    context "when the object is moving" do
      let(:pos) { Vector[10, 0, 0] }
      let(:velocity) { Vector[0, 10, 0] }
      let(:angular_velocity) { Vector[0, 0, 0] }
      let(:mass) { 2 }

      it "is perpendicular to momentum and position and 200 in magnitude" do
        expect(rigidbody.angular_momentum).to eq(Vector[0, 0, 200])
      end
    end

    context "when the object is moving and spinning" do
      let(:pos) { Vector[10, 0, 0] }
      let(:velocity) { Vector[0, 10, 0] }
      let(:angular_velocity) { Vector[0, 5, 0] }
      let(:mass) { 2 }

      it "is the sum of the two angular momentum vectors" do
        expect(rigidbody.angular_momentum).to eq(Vector[0, 10, 200])
      end

      context "when using a different origin" do
        let(:origin) { Vector[5, 0, 0] }

        it "is the sum of the two angular momentum vectors" do
          expect(rigidbody.angular_momentum(origin)).to eq(Vector[0, 10, 100])
        end
      end
    end
  end

  describe "#velocity_at_point" do
    let(:rigidbody) do
      described_class.new(
        velocity:,
        angular_velocity:,
        gravity: Vector[0, 0, 0],
        mass: 1
      )
    end
    let!(:rigidbody_object) do
      Engine::GameObject.new(
        "rigidbody_object",
        pos:,
        components: [rigidbody]
      )
    end

    context "when stationary" do
      let(:pos) { Vector[0, 0, 0] }
      let(:velocity) { Vector[0, 0, 0] }
      let(:angular_velocity) { Vector[0, 0, 0] }

      it "is the same as the object's velocity" do
        expect(rigidbody.velocity_at_point(Vector[0, 0, 0])).to eq(Vector[0, 0, 0])
      end
    end

    context "when moving" do
      let(:pos) { Vector[0, 0, 0] }
      let(:velocity) { Vector[1, 0, 0] }
      let(:angular_velocity) { Vector[0, 0, 0] }

      it "is the same as the object's velocity" do
        expect(rigidbody.velocity_at_point(Vector[0, 0, 0])).to eq(Vector[1, 0, 0])
        expect(rigidbody.velocity_at_point(Vector[1, 0, 0])).to eq(Vector[1, 0, 0])
      end
    end

    context "when spinning" do
      let(:pos) { Vector[0, 0, 0] }
      let(:velocity) { Vector[0, 0, 0] }
      let(:angular_velocity) { Vector[0, 5, 0] }

      it "is the cross product of the angular velocity and the position" do
        expect(rigidbody.velocity_at_point(Vector[1, 0, 0])).to eq(Vector[0, 0, 5 * Math::PI / 180])
        expect(rigidbody.velocity_at_point(Vector[0, 1, 0])).to eq(Vector[0, 0, 0])
      end
    end

    context "when moving and spinning" do
      let(:pos) { Vector[0, 0, 10] }
      let(:velocity) { Vector[1, 0, 0] }
      let(:angular_velocity) { Vector[0, 5, 0] }

      it "is the sum of the object's velocity and the cross product of the angular velocity and the position" do
        expect(rigidbody.velocity_at_point(Vector[1, 0, 10])).to eq(Vector[1, 0, 5 * Math::PI / 180])
        expect(rigidbody.velocity_at_point(Vector[0, 1, 10])).to eq(Vector[1, 0, 0])
      end
    end
  end
end
