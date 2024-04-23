# frozen_string_literal: true

describe Engine::GameObject do
  describe ".new" do
    it 'creates the object' do
      expect(Engine::GameObject.new).to be_a(Engine::GameObject)
    end

    it "sets the position of the object" do
      object = Engine::GameObject.new(pos: Engine::Vector.new(10, 20))

      expect(object.x).to eq(10)
      expect(object.y).to eq(20)
    end

    it "sets the rotation of the object" do
      object = Engine::GameObject.new(rotation: 90)

      expect(object.rotation).to eq(90)
    end

    it "sets the name of the object" do
      object = Engine::GameObject.new("Test Object")

      expect(object.name).to eq("Test Object")
    end

    it "sets the components of the object" do
      component = Engine::Component.new
      object = Engine::GameObject.new(components: [component])

      expect(object.components).to eq([component])
    end

    it "calls start on all components" do
      component = Engine::Component.new
      expect(component).to receive(:start)
      Engine::GameObject.new(components: [component])
    end

    it "sets the game object on all components" do
      component = Engine::Component.new
      object = Engine::GameObject.new(components: [component])

      expect(component.game_object).to eq(object)
    end

    it "adds the object to the list of objects" do
      object = Engine::GameObject.new

      expect(Engine::GameObject.objects).to include(object)
    end
  end

  describe ".update_all" do
    let(:component) { Engine::Component.new }
    let!(:object) { Engine::GameObject.new(components: [component]) }

    it 'calls update on all components' do
      expect(component).to receive(:update)

      Engine::GameObject.update_all(0.1)
    end
  end

  describe "#x" do
    it "returns the x position of the object" do
      object = Engine::GameObject.new(pos: Engine::Vector.new(10, 20))

      expect(object.x).to eq(10)
    end
  end

  describe "#x=" do
    it "sets the x position of the object" do
      object = Engine::GameObject.new

      object.x = 10

      expect(object.x).to eq(10)
    end
  end

  describe "#y" do
    it "returns the y position of the object" do
      object = Engine::GameObject.new(pos: Engine::Vector.new(10, 20))

      expect(object.y).to eq(20)
    end
  end

  describe "#y=" do
    it "sets the y position of the object" do
      object = Engine::GameObject.new

      object.y = 20

      expect(object.y).to eq(20)
    end
  end

  describe "#local_to_world_coordinate" do
    it "converts local coordinates to world coordinates" do
      object = Engine::GameObject.new(pos: Engine::Vector.new(10, 20), rotation: 90)

      result = object.local_to_world_coordinate(10, 0)

      expect(result.x).to be_within(0.0001).of(10)
      expect(result.y).to be_within(0.0001).of(30)
    end
  end

  describe "#model_matrix" do
    it "returns the model matrix of the object" do
      object = Engine::GameObject.new(pos: Engine::Vector.new(10, 20), rotation: 90)

      result = object.model_matrix

      expected_matrix = [
        0, 1, 0, 0,
        -1, 0, 0, 0,
        0, 0, 1, 0,
        10, 20, 0, 1
      ]

      expected_matrix.each_with_index do |value, index|
        expect(result[index]).to be_within(0.0001).of(value)
      end
    end
  end

  describe "#destroy!" do
    it "removes the object from the list of objects" do
      object = Engine::GameObject.new

      object.destroy!
      expect(Engine::GameObject.objects).not_to include(object)
    end
  end

  describe ".destroy_all" do
    it "destroys all objects" do
      object = Engine::GameObject.new("a")
      object2 = Engine::GameObject.new("b")

      Engine::GameObject.destroy_all
      expect(Engine::GameObject.objects).to be_empty
    end
  end
end
