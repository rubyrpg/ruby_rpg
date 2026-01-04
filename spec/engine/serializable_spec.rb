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

  def initialize(name)
    @name = name
  end
end

class TestChild < TestParent
  serialize :age
  attr_reader :age

  def initialize(name, age)
    super(name)
    @age = age
  end
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

  describe "#to_serialized" do
    it "serializes primitives with class tags" do
      klass = Class.new do
        include Engine::Serializable
        serialize :name, :age

        def initialize(name, age)
          @name = name
          @age = age
        end
      end

      instance = klass.new("test", 42)
      result = instance.to_serialized

      expect(result[:name]).to eq({ _class: "String", value: "test" })
      expect(result[:age]).to eq({ _class: "Integer", value: 42 })
    end

    it "includes uuid and class in output" do
      instance = TestSerializableClass.new
      result = instance.to_serialized

      expect(result[:uuid]).to eq(instance.uuid)
      expect(result[:_class]).to eq("TestSerializableClass")
    end

    it "serializes nested Serializable objects as references" do
      inner = TestSerializableClass.new
      klass = Class.new do
        include Engine::Serializable
        serialize :child
      end

      instance = klass.new
      instance.instance_variable_set(:@child, inner)
      result = instance.to_serialized

      expect(result[:child]).to eq({ _class: "TestSerializableClass", _ref: inner.uuid })
    end

    it "serializes hashes recursively" do
      klass = Class.new do
        include Engine::Serializable
        serialize :uniforms
      end

      instance = klass.new
      instance.instance_variable_set(:@uniforms, { shininess: 0.5, name: "metal" })
      result = instance.to_serialized

      expect(result[:uniforms]).to eq({
        _class: "Hash",
        value: {
          shininess: { _class: "Float", value: 0.5 },
          name: { _class: "String", value: "metal" }
        }
      })
    end

    it "serializes arrays recursively" do
      klass = Class.new do
        include Engine::Serializable
        serialize :items
      end

      instance = klass.new
      instance.instance_variable_set(:@items, [1, "two", 3.0])
      result = instance.to_serialized

      expect(result[:items]).to eq({
        _class: "Array",
        value: [
          { _class: "Integer", value: 1 },
          { _class: "String", value: "two" },
          { _class: "Float", value: 3.0 }
        ]
      })
    end

    it "serializes references inside hashes" do
      inner = TestSerializableClass.new
      klass = Class.new do
        include Engine::Serializable
        serialize :data
      end

      instance = klass.new
      instance.instance_variable_set(:@data, { child: inner })
      result = instance.to_serialized

      expect(result[:data][:value][:child]).to eq({ _class: "TestSerializableClass", _ref: inner.uuid })
    end
  end

  describe ".from_serialized" do
    it "reconstructs an object from serialized data" do
      data = {
        _class: "TestSerializableClass",
        uuid: "abc-123"
      }

      instance = Engine::Serializable.from_serialized(data)

      expect(instance).to be_a(TestSerializableClass)
      expect(instance.uuid).to eq("abc-123")
    end

    it "rejects classes that don't include Serializable" do
      data = {
        _class: "String",
        value: "hacked"
      }

      expect {
        Engine::Serializable.from_serialized(data)
      }.to raise_error(Engine::Serializable::UnauthorizedClassError)
    end

    it "deserializes primitive attributes" do
      data = {
        _class: "TestPrimitives",
        uuid: "xyz-789",
        name: { _class: "String", value: "test" },
        age: { _class: "Integer", value: 42 }
      }

      instance = Engine::Serializable.from_serialized(data)

      expect(instance.name).to eq("test")
      expect(instance.age).to eq(42)
    end

    it "deserializes hashes" do
      data = {
        _class: "TestWithHash",
        uuid: "hash-123",
        uniforms: {
          _class: "Hash",
          value: {
            shininess: { _class: "Float", value: 0.5 },
            name: { _class: "String", value: "metal" }
          }
        }
      }

      instance = Engine::Serializable.from_serialized(data)

      expect(instance.uniforms).to eq({ shininess: 0.5, name: "metal" })
    end

    it "deserializes arrays" do
      data = {
        _class: "TestWithArray",
        uuid: "arr-123",
        items: {
          _class: "Array",
          value: [
            { _class: "Integer", value: 1 },
            { _class: "String", value: "two" }
          ]
        }
      }

      instance = Engine::Serializable.from_serialized(data)

      expect(instance.items).to eq([1, "two"])
    end
  end

  describe ".deserialize_all" do
    it "deserializes multiple objects and resolves references" do
      child_data = {
        _class: "TestSerializableClass",
        uuid: "child-uuid"
      }

      parent_data = {
        _class: "TestWithRef",
        uuid: "parent-uuid",
        child: { _class: "TestSerializableClass", _ref: "child-uuid" }
      }

      objects = Engine::Serializable.deserialize_all([child_data, parent_data])

      parent = objects.find { |o| o.uuid == "parent-uuid" }
      child = objects.find { |o| o.uuid == "child-uuid" }

      expect(parent.child).to eq(child)
    end

    it "handles references inside hashes" do
      child_data = {
        _class: "TestSerializableClass",
        uuid: "child-uuid"
      }

      parent_data = {
        _class: "TestWithHash",
        uuid: "parent-uuid",
        uniforms: {
          _class: "Hash",
          value: {
            texture: { _class: "TestSerializableClass", _ref: "child-uuid" }
          }
        }
      }

      objects = Engine::Serializable.deserialize_all([child_data, parent_data])

      parent = objects.find { |o| o.uuid == "parent-uuid" }
      child = objects.find { |o| o.uuid == "child-uuid" }

      expect(parent.uniforms[:texture]).to eq(child)
    end

    it "handles references inside arrays" do
      child_data = {
        _class: "TestSerializableClass",
        uuid: "child-uuid"
      }

      parent_data = {
        _class: "TestWithArray",
        uuid: "parent-uuid",
        items: {
          _class: "Array",
          value: [
            { _class: "TestSerializableClass", _ref: "child-uuid" }
          ]
        }
      }

      objects = Engine::Serializable.deserialize_all([child_data, parent_data])

      parent = objects.find { |o| o.uuid == "parent-uuid" }
      child = objects.find { |o| o.uuid == "child-uuid" }

      expect(parent.items.first).to eq(child)
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

    it "serializes inherited attributes" do
      instance = TestChild.new("bob", 25)
      result = instance.to_serialized

      expect(result[:name]).to eq({ _class: "String", value: "bob" })
      expect(result[:age]).to eq({ _class: "Integer", value: 25 })
    end

    it "deserializes inherited attributes" do
      data = {
        _class: "TestChild",
        uuid: "child-123",
        name: { _class: "String", value: "alice" },
        age: { _class: "Integer", value: 30 }
      }

      instance = Engine::Serializable.from_serialized(data)

      expect(instance.name).to eq("alice")
      expect(instance.age).to eq(30)
    end
  end

  describe "edge cases" do
    it "serializes nil values" do
      klass = Class.new do
        include Engine::Serializable
        serialize :value
      end

      instance = klass.new
      instance.instance_variable_set(:@value, nil)
      result = instance.to_serialized

      expect(result[:value]).to eq({ _class: "NilClass", value: nil })
    end

    it "serializes booleans" do
      klass = Class.new do
        include Engine::Serializable
        serialize :enabled, :disabled
      end

      instance = klass.new
      instance.instance_variable_set(:@enabled, true)
      instance.instance_variable_set(:@disabled, false)
      result = instance.to_serialized

      expect(result[:enabled]).to eq({ _class: "TrueClass", value: true })
      expect(result[:disabled]).to eq({ _class: "FalseClass", value: false })
    end

    it "serializes symbols" do
      klass = Class.new do
        include Engine::Serializable
        serialize :mode
      end

      instance = klass.new
      instance.instance_variable_set(:@mode, :fast)
      result = instance.to_serialized

      expect(result[:mode]).to eq({ _class: "Symbol", value: "fast" })
    end

    it "deserializes symbols" do
      data = {
        _class: "TestPrimitives",
        uuid: "sym-123",
        name: { _class: "Symbol", value: "test_sym" },
        age: { _class: "Integer", value: 1 }
      }

      instance = Engine::Serializable.from_serialized(data)

      expect(instance.name).to eq(:test_sym)
    end

    it "serializes vectors" do
      klass = Class.new do
        include Engine::Serializable
        serialize :position
      end

      instance = klass.new
      instance.instance_variable_set(:@position, Vector[1.0, 2.0, 3.0])
      result = instance.to_serialized

      expect(result[:position]).to eq({ _class: "Vector", value: [1.0, 2.0, 3.0] })
    end

    it "deserializes vectors" do
      data = {
        _class: "TestWithArray",
        uuid: "vec-123",
        items: { _class: "Vector", value: [4.0, 5.0, 6.0] }
      }

      instance = Engine::Serializable.from_serialized(data)

      expect(instance.items).to eq(Vector[4.0, 5.0, 6.0])
    end

    it "serializes matrices" do
      klass = Class.new do
        include Engine::Serializable
        serialize :transform
      end

      instance = klass.new
      instance.instance_variable_set(:@transform, Matrix[[1, 0], [0, 1]])
      result = instance.to_serialized

      expect(result[:transform]).to eq({ _class: "Matrix", value: [[1, 0], [0, 1]] })
    end

    it "deserializes matrices" do
      data = {
        _class: "TestWithArray",
        uuid: "mat-123",
        items: { _class: "Matrix", value: [[1, 2], [3, 4]] }
      }

      instance = Engine::Serializable.from_serialized(data)

      expect(instance.items).to eq(Matrix[[1, 2], [3, 4]])
    end

    it "serializes quaternions" do
      klass = Class.new do
        include Engine::Serializable
        serialize :rotation
      end

      instance = klass.new
      instance.instance_variable_set(:@rotation, Engine::Quaternion.new(1.0, 0.0, 0.0, 0.0))
      result = instance.to_serialized

      expect(result[:rotation]).to eq({ _class: "Engine::Quaternion", value: [1.0, 0.0, 0.0, 0.0] })
    end

    it "deserializes quaternions" do
      data = {
        _class: "TestWithArray",
        uuid: "quat-123",
        items: { _class: "Engine::Quaternion", value: [0.707, 0.707, 0.0, 0.0] }
      }

      instance = Engine::Serializable.from_serialized(data)

      expect(instance.items).to be_a(Engine::Quaternion)
      expect(instance.items.w).to eq(0.707)
      expect(instance.items.x).to eq(0.707)
      expect(instance.items.y).to eq(0.0)
      expect(instance.items.z).to eq(0.0)
    end
  end

  describe "custom factory serialization" do
    it "uses serializable_data when defined" do
      klass = Class.new do
        include Engine::Serializable
        attr_reader :path

        def initialize(path)
          @path = path
        end

        def serializable_data
          { path: @path }
        end
      end
      stub_const("TestFactoryClass", klass)

      instance = klass.new("/textures/wood.png")
      parent = Class.new do
        include Engine::Serializable
        serialize :asset
      end

      wrapper = parent.new
      wrapper.instance_variable_set(:@asset, instance)
      result = wrapper.to_serialized

      expect(result[:asset]).to eq({ _class: "TestFactoryClass", path: "/textures/wood.png" })
    end

    it "uses from_serializable_data when defined" do
      klass = Class.new do
        include Engine::Serializable
        attr_reader :path

        def initialize(path)
          @path = path
        end

        def self.from_serializable_data(data)
          new(data[:path])
        end
      end
      stub_const("TestFactoryClass2", klass)
      Engine::Serializable.register_class(klass)

      data = { _class: "TestFactoryClass2", path: "/textures/metal.png" }
      instance = Engine::Serializable.deserialize_value(data)

      expect(instance).to be_a(klass)
      expect(instance.path).to eq("/textures/metal.png")
    end
  end

  describe "file I/O" do
    let(:temp_file) { "/tmp/test_serializable_#{SecureRandom.hex(4)}.yaml" }

    after { File.delete(temp_file) if File.exist?(temp_file) }

    it "saves to a YAML file" do
      instance = TestPrimitives.new
      instance.instance_variable_set(:@name, "test")
      instance.instance_variable_set(:@age, 25)

      instance.to_file(temp_file)

      expect(File.exist?(temp_file)).to be true
      content = YAML.load_file(temp_file, permitted_classes: [Symbol])
      expect(content[:_class]).to eq("TestPrimitives")
    end

    it "loads from a YAML file" do
      data = {
        _class: "TestPrimitives",
        uuid: "file-123",
        name: { _class: "String", value: "loaded" },
        age: { _class: "Integer", value: 30 }
      }
      File.write(temp_file, data.to_yaml)

      instance = Engine::Serializable.from_file(temp_file)

      expect(instance).to be_a(TestPrimitives)
      expect(instance.name).to eq("loaded")
      expect(instance.age).to eq(30)
    end

    it "loads multiple objects with references from files" do
      child_file = "/tmp/child_#{SecureRandom.hex(4)}.yaml"
      parent_file = "/tmp/parent_#{SecureRandom.hex(4)}.yaml"

      child_data = { _class: "TestSerializableClass", uuid: "child-file-uuid" }
      parent_data = {
        _class: "TestWithRef",
        uuid: "parent-file-uuid",
        child: { _class: "TestSerializableClass", _ref: "child-file-uuid" }
      }

      File.write(child_file, child_data.to_yaml)
      File.write(parent_file, parent_data.to_yaml)

      objects = Engine::Serializable.from_files([child_file, parent_file])

      parent = objects.find { |o| o.uuid == "parent-file-uuid" }
      child = objects.find { |o| o.uuid == "child-file-uuid" }

      expect(parent.child).to eq(child)
    ensure
      File.delete(child_file) if File.exist?(child_file)
      File.delete(parent_file) if File.exist?(parent_file)
    end
  end

  describe "uuid" do
    it "generates a uuid on first access" do
      instance = test_class.new
      expect(instance.uuid).to match(/\A[0-9a-f-]{36}\z/)
    end

    it "returns the same uuid on subsequent accesses" do
      instance = test_class.new
      uuid = instance.uuid
      expect(instance.uuid).to eq(uuid)
    end

    it "generates unique uuids for different instances" do
      instance1 = test_class.new
      instance2 = test_class.new
      expect(instance1.uuid).not_to eq(instance2.uuid)
    end
  end
end
