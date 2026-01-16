# frozen_string_literal: true

class TestSerializableClass
  include Engine::Serializable
end

class TestPrimitives
  include Engine::Serializable
  serialize :name, :age
  attr_reader :name, :age
end

class TestWithHash
  include Engine::Serializable
  serialize :uniforms
  attr_reader :uniforms
end

class TestWithArray
  include Engine::Serializable
  serialize :items
  attr_reader :items
end

class TestWithRef
  include Engine::Serializable
  serialize :child
  attr_reader :child
end

class TestParent
  include Engine::Serializable
  serialize :name
  attr_reader :name
end

class TestChild < TestParent
  serialize :age
  attr_reader :age
end

describe Engine::Serializable do
  let(:test_class) do
    Class.new do
      include Engine::Serializable
    end
  end

  describe ".serialize" do
    it "adds the attribute to the list of serializable attributes" do
      klass = Class.new do
        include Engine::Serializable
        serialize :name, :age
      end

      expect(klass.serializable_attributes).to eq([:name, :age])
    end

    it "can be called multiple times" do
      klass = Class.new do
        include Engine::Serializable
        serialize :name
        serialize :age
      end

      expect(klass.serializable_attributes).to eq([:name, :age])
    end
  end

  describe "inheritance" do
    it "inherits serializable attributes from parent class" do
      parent = Class.new do
        include Engine::Serializable
        serialize :name
      end

      child = Class.new(parent) do
        serialize :age
      end

      expect(child.serializable_attributes).to eq([:name, :age])
    end

    it "does not modify parent's attributes when child adds new ones" do
      parent = Class.new do
        include Engine::Serializable
        serialize :name
      end

      Class.new(parent) do
        serialize :age
      end

      expect(parent.serializable_attributes).to eq([:name])
    end
  end

  describe ".create" do
    it "creates an object with named attributes and calls awake" do
      test_class = Class.new do
        include Engine::Serializable
        serialize :name, :value

        attr_reader :name, :value, :awake_was_called

        define_method(:awake) do
          @awake_was_called = true
        end
      end
      Engine::Serializable.register_class(test_class)

      instance = test_class.create(name: "test", value: 42)

      expect(instance.name).to eq("test")
      expect(instance.value).to eq(42)
      expect(instance.awake_was_called).to be true
    end

    it "generates a uuid" do
      instance = TestPrimitives.create(name: "test", age: 25)

      expect(instance.uuid).to match(/\A[0-9a-f-]{36}\z/)
    end
  end

  describe "uuid" do
    it "generates a uuid on first access" do
      instance = test_class.create
      expect(instance.uuid).to match(/\A[0-9a-f-]{36}\z/)
    end

    it "returns the same uuid on subsequent accesses" do
      instance = test_class.create
      uuid = instance.uuid
      expect(instance.uuid).to eq(uuid)
    end

    it "generates unique uuids for different instances" do
      instance1 = test_class.create
      instance2 = test_class.create
      expect(instance1.uuid).not_to eq(instance2.uuid)
    end
  end

  describe "class registry" do
    it "registers classes that include Serializable" do
      expect(Engine::Serializable.allowed_class?("TestSerializableClass")).to be true
    end

    it "can retrieve registered classes by name" do
      expect(Engine::Serializable.get_class("TestSerializableClass")).to eq(TestSerializableClass)
    end

    it "registers subclasses automatically" do
      expect(Engine::Serializable.allowed_class?("TestChild")).to be true
    end

    it "can manually register a class" do
      klass = Class.new do
        include Engine::Serializable
      end
      stub_const("ManuallyRegistered", klass)
      Engine::Serializable.register_class(klass)

      expect(Engine::Serializable.allowed_class?("ManuallyRegistered")).to be true
    end
  end

  describe "initialize prevention" do
    it "raises error when trying to define initialize" do
      expect {
        Class.new do
          include Engine::Serializable

          def initialize
          end
        end
      }.to raise_error(Engine::Serializable::InitializeNotAllowedError)
    end
  end

  describe "awake" do
    it "provides a default empty implementation" do
      instance = test_class.create
      expect { instance.awake }.not_to raise_error
    end

    it "can be overridden in subclasses" do
      value_set = nil
      klass = Class.new do
        include Engine::Serializable
        define_method(:awake) { value_set = "awake called" }
      end

      klass.create
      expect(value_set).to eq("awake called")
    end
  end
end
