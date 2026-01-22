# frozen_string_literal: true

describe Engine::GameObject do
  describe ".create" do
    it 'creates the object' do
      expect(Engine::GameObject.create).to be_a(Engine::GameObject)
    end

    it "sets the position of the object" do
      object = Engine::GameObject.create(pos: Vector[10, 20])

      expect(object.x).to eq(10)
      expect(object.y).to eq(20)
    end

    it "sets the rotation of the object" do
      object = Engine::GameObject.create(rotation: 90)

      expect(object.rotation.to_euler).to be_vector(Vector[0, 0, 90])
    end

    it "sets the name of the object" do
      object = Engine::GameObject.create(name: "Test Object")

      expect(object.name).to eq("Test Object")
    end

    it "sets the components of the object" do
      component = Engine::Component.create
      object = Engine::GameObject.create(components: [component])

      expect(object.components).to eq([component])
    end

    it "calls start on all components" do
      component = Engine::Component.create
      expect(component).to receive(:start)
      Engine::GameObject.create(components: [component])
    end

    it "sets the game object on all components" do
      component = Engine::Component.create
      object = Engine::GameObject.create(components: [component])

      expect(component.game_object).to eq(object)
    end

    it "adds the object to the list of objects" do
      object = Engine::GameObject.create

      expect(Engine::GameObject.objects).to include(object)
    end
  end

  describe ".update_all" do
    let(:component) { Engine::Component.create }
    let!(:object) { Engine::GameObject.create(components: [component]) }

    it 'calls update on all components' do
      expect(component).to receive(:update)

      Engine::GameObject.update_all(0.1)
    end
  end

  describe "#x" do
    it "returns the x position of the object" do
      object = Engine::GameObject.create(pos: Vector[10, 20])

      expect(object.x).to eq(10)
    end
  end

  describe "#x=" do
    it "sets the x position of the object" do
      object = Engine::GameObject.create

      object.x = 10

      expect(object.x).to eq(10)
    end
  end

  describe "#y" do
    it "returns the y position of the object" do
      object = Engine::GameObject.create(pos: Vector[10, 20])

      expect(object.y).to eq(20)
    end
  end

  describe "#z=" do
    it "sets the z position of the object" do
      object = Engine::GameObject.create

      object.z = 20

      expect(object.z).to eq(20)
    end
  end

  describe "#local_to_world_coordinate" do
    it "converts local coordinates to world coordinates when the object is at 0,0" do
      object = Engine::GameObject.create(pos: Vector[0.0, 0.0])

      result = object.local_to_world_coordinate(Vector[10.0, 0.0, 0.0])

      expect(result).to eq(Vector[10, 0, 0])
    end

    it "converts local coordinates to world coordinates" do
      object = Engine::GameObject.create(pos: Vector[10.0, 20.0], rotation: 0.0)

      result = object.local_to_world_coordinate(Vector[10.0, 0.0, 0.0])

      expect(result).to eq(Vector[20, 20, 0])
    end

    it "converts local coordinates to world coordinates when rotated" do
      object = Engine::GameObject.create(pos: Vector[10, 20], rotation: 90)

      result = object.local_to_world_coordinate(Vector[10, 0, 0])

      expect(result).to be_vector(Vector[10, 10, 0])
    end

    context "when the object has a parent" do
      let(:parent) { Engine::GameObject.create }
      let(:object) { Engine::GameObject.create(parent: parent) }

      it "converts local coordinates to world coordinates" do
        parent.pos = Vector[10, 20, 0]
        object.pos = Vector[10, 20, 0]
        expect(object.local_to_world_coordinate(Vector[10, 0, 0])).to eq(Vector[30, 40, 0])

        parent.pos = Vector[20, 30, 0]
        object.pos = Vector[10, 20, 0]

        expect(object.local_to_world_coordinate(Vector[10, 0, 0])).to eq(Vector[40, 50, 0])

        parent.pos = Vector[200, 30, 0]
        object.pos = Vector[20, 30, 0]

        expect(object.local_to_world_coordinate(Vector[10, 0, 0])).to eq(Vector[230, 60, 0])

        parent.pos = Vector[0, 0, 0]
        parent.rotation = Engine::Quaternion.from_euler(Vector[0, 90, 0])
        object.pos = Vector[0, 0, 0]

        expect(parent.local_to_world_coordinate(Vector[10, 0, 0])).to be_vector(Vector[0, 0, 10])
        expect(object.local_to_world_coordinate(Vector[10, 0, 0])).to be_vector(Vector[0, 0, 10])

        parent.pos = Vector[0, 0, 0]
        parent.rotation = Engine::Quaternion.from_euler(Vector[0, 90, 0])
        object.pos = Vector[10, 0, 0]

        expect(object.local_to_world_coordinate(Vector[10, 0, 0])).to be_vector(Vector[0, 0, 20])
      end
    end
  end

  describe "#model_matrix" do
    it "returns the model matrix of the object" do
      object = Engine::GameObject.create(pos: Vector[10, 20], rotation: 90)

      result = object.model_matrix

      expected_matrix = Matrix[
        [0, -1, 0, 0],
        [1, 0, 0, 0],
        [0, 0, 1, 0],
        [10, 20, 0, 1]
      ].to_a.flatten

      expected_matrix.each_with_index do |value, index|
        expect(result.to_a.flatten[index]).to be_within(0.0001).of(value)
      end
    end

    context "when the object has a parent" do
      it "returns the model matrix of the object" do
        parent = Engine::GameObject.create(pos: Vector[10, 20, 0], rotation: Vector[0, 0, 90])
        object = Engine::GameObject.create(pos: Vector[10, 20, 0], parent: parent)

        result = object.model_matrix

        expected_matrix = Matrix[
          [0, -1, 0, 0],
          [1, 0, 0, 0],
          [0, 0, 1, 0],
          [30, 10, 0, 1]
        ].to_a.flatten

        expected_matrix.each_with_index do |value, index|
          expect(result.to_a.flatten[index]).to be_within(0.0001).of(value)
        end
      end
    end
  end

  describe "#destroy!" do
    it "removes the object from the list of objects" do
      object = Engine::GameObject.create

      object.destroy!
      Engine::GameObject.erase_destroyed_objects
      expect(Engine::GameObject.objects).not_to include(object)
    end

    it "calls destroy on all components" do
      component = Engine::Component.create
      object = Engine::GameObject.create(components: [component])

      expect(component).to receive(:destroy!)

      object.destroy!
    end
  end

  describe ".destroy_all" do
    it "destroys all objects" do
      object = Engine::GameObject.create(name: "a")
      object2 = Engine::GameObject.create(name: "b")

      Engine::GameObject.destroy_all
      Engine::GameObject.erase_destroyed_objects
      expect(Engine::GameObject.objects).to be_empty
    end
  end

  describe "#right, #up and #forward" do
    it "returns the direction vectors of the object" do
      object = Engine::GameObject.create(pos: Vector[10, 20, 0], rotation: Vector[0, 0, 0])

      expect((object.right - Vector[1, 0, 0]).magnitude).to be_within(0.0001).of(0)
      expect((object.up - Vector[0, 1, 0]).magnitude).to be_within(0.0001).of(0)
      expect((object.forward - Vector[0, 0, 1]).magnitude).to be_within(0.0001).of(0)
    end

    it "returns the direction vectors of the object when rotated" do
      object = Engine::GameObject.create(pos: Vector[10, 20, 0], rotation: Vector[0, 90, 0])

      expect((object.right - Vector[0, 0, 1]).magnitude).to be_within(0.0001).of(0)
      expect((object.up - Vector[0, 1, 0]).magnitude).to be_within(0.0001).of(0)
      expect((object.forward - Vector[-1, 0, 0]).magnitude).to be_within(0.0001).of(0)

      object.rotation = Engine::Quaternion.from_euler(Vector[90, 0, 0])

      expect((object.right - Vector[1, 0, 0]).magnitude).to be_within(0.0001).of(0)
      expect((object.up - Vector[0, 0, -1]).magnitude).to be_within(0.0001).of(0)
      expect((object.forward - Vector[0, 1, 0]).magnitude).to be_within(0.0001).of(0)
    end
  end

  describe "parent" do
    it "sets the parent of the object when creating the child" do
      parent = Engine::GameObject.create
      object = Engine::GameObject.create(parent: parent)

      expect(object.parent).to eq(parent)
    end

    it "sets the children of the parent when creating the child" do
      parent = Engine::GameObject.create
      object = Engine::GameObject.create(parent: parent)

      expect(parent.children).to include(object)
    end

    it "sets the parent of the object" do
      parent = Engine::GameObject.create
      object = Engine::GameObject.create

      object.parent = parent

      expect(object.parent).to eq(parent)
    end

    it "sets the children of the parent" do
      parent = Engine::GameObject.create
      object = Engine::GameObject.create

      object.parent = parent

      expect(parent.children).to include(object)
    end

    it "removes the object from the parent's children when destroyed" do
      parent = Engine::GameObject.create
      object = Engine::GameObject.create(parent: parent)

      object.destroy!
      Engine::GameObject.erase_destroyed_objects

      expect(parent.children).not_to include(object)
    end

    it "destroys the children when the parent is destroyed" do
      parent = Engine::GameObject.create
      object = Engine::GameObject.create(parent: parent)

      parent.destroy!
      Engine::GameObject.erase_destroyed_objects

      expect(Engine::GameObject.objects).not_to include(object)
    end

    it "sets the parent of the children to nil when the parent is removed" do
      parent = Engine::GameObject.create
      object = Engine::GameObject.create(parent: parent)

      object.parent = nil

      expect(object.parent).to be_nil
    end

    it "removes the object from the parent's children when the parent is removed" do
      parent = Engine::GameObject.create
      object = Engine::GameObject.create(parent: parent)

      object.parent = nil

      expect(parent.children).not_to include(object)
    end
  end

  describe "#rotate_around" do
    it "rotates the object around the z axis" do
      object = Engine::GameObject.create(rotation: Vector[1, 2, 3])

      object.rotate_around(Vector[0, 0, 1], 90)

      expect(object.rotation).to eq((Engine::Quaternion.from_angle_axis(90, Vector[0, 0, 1]) * Engine::Quaternion.from_euler(Vector[1, 2, 3])))
    end

    it "rotates the object around multiple axes" do
      object = Engine::GameObject.create(rotation: Vector[1, 2, 3])

      object.rotate_around(Vector[0, 1, 1], 90)

      expect(object.rotation)
        .to eq((Engine::Quaternion.from_angle_axis(90, Vector[0, 1, 1]) * Engine::Quaternion.from_euler(Vector[1, 2, 3])))
    end
  end

  describe "#component" do
    it "returns the first component of the given type" do
      component = Engine::Component.create
      object = Engine::GameObject.create(components: [component])

      expect(object.component(Engine::Component)).to eq(component)
    end

    it "returns nil when no component of the given type exists" do
      object = Engine::GameObject.create

      expect(object.component(Engine::Component)).to be_nil
    end

    it "caches the result" do
      component = Engine::Component.create
      object = Engine::GameObject.create(components: [component])

      result1 = object.component(Engine::Component)
      result2 = object.component(Engine::Component)

      expect(result1).to equal(result2)
    end
  end

  describe "#components_of_type" do
    it "returns all components of the given type" do
      component1 = Engine::Component.create
      component2 = Engine::Component.create
      object = Engine::GameObject.create(components: [component1, component2])

      expect(object.components_of_type(Engine::Component)).to eq([component1, component2])
    end

    it "returns empty array when no components of the given type exist" do
      object = Engine::GameObject.create

      expect(object.components_of_type(Engine::Component)).to eq([])
    end

    it "caches the result" do
      component = Engine::Component.create
      object = Engine::GameObject.create(components: [component])

      result1 = object.components_of_type(Engine::Component)
      result2 = object.components_of_type(Engine::Component)

      expect(result1).to equal(result2)
    end
  end

  describe "#all_components" do
    it "returns components, renderers, and ui_renderers combined" do
      component = Engine::Component.create
      object = Engine::GameObject.create(components: [component])

      expect(object.all_components).to include(component)
    end
  end
end
