# frozen_string_literal: true

require_relative "../../spec_helper"

class TestSerializable
  include Engine::Serializable
  serialize :name, :age
  attr_reader :name, :age
end

class TestWithChild
  include Engine::Serializable
  serialize :child
  attr_reader :child
end

class TestEmpty
  include Engine::Serializable
end

describe Engine::Serialization::ObjectSerializer do
  describe ".serialize" do
    it "returns a hash with _class and uuid" do
      obj = TestEmpty.create
      result = described_class.serialize(obj)

      expect(result[:_class]).to eq("TestEmpty")
      expect(result[:uuid]).to eq(obj.uuid)
    end

    it "serializes primitive attributes" do
      obj = TestSerializable.create(name: "Alice", age: 30)
      result = described_class.serialize(obj)

      expect(result[:name]).to eq({ _class: "String", value: "Alice" })
      expect(result[:age]).to eq({ _class: "Integer", value: 30 })
    end

    it "serializes nil values" do
      obj = TestSerializable.create(name: nil, age: nil)
      result = described_class.serialize(obj)

      expect(result[:name]).to eq({ _class: "NilClass", value: nil })
    end

    it "serializes booleans" do
      klass = Class.new do
        include Engine::Serializable
        serialize :enabled
        attr_reader :enabled
      end

      obj = klass.create(enabled: true)
      result = described_class.serialize(obj)

      expect(result[:enabled]).to eq({ _class: "TrueClass", value: true })
    end

    it "serializes symbols" do
      klass = Class.new do
        include Engine::Serializable
        serialize :mode
        attr_reader :mode
      end

      obj = klass.create(mode: :fast)
      result = described_class.serialize(obj)

      expect(result[:mode]).to eq({ _class: "Symbol", value: "fast" })
    end

    it "serializes references to other Serializable objects as refs" do
      child = TestEmpty.create
      parent = TestWithChild.create(child: child)

      result = described_class.serialize(parent)

      expect(result[:child]).to eq({ _class: "TestEmpty", _ref: child.uuid })
    end

    it "serializes arrays recursively" do
      klass = Class.new do
        include Engine::Serializable
        serialize :items
        attr_reader :items
      end

      obj = klass.create(items: [1, "two", 3.0])
      result = described_class.serialize(obj)

      expect(result[:items]).to eq({
        _class: "Array",
        value: [
          { _class: "Integer", value: 1 },
          { _class: "String", value: "two" },
          { _class: "Float", value: 3.0 }
        ]
      })
    end

    it "serializes hashes recursively" do
      klass = Class.new do
        include Engine::Serializable
        serialize :data
        attr_reader :data
      end

      obj = klass.create(data: { a: 1, b: "two" })
      result = described_class.serialize(obj)

      expect(result[:data]).to eq({
        _class: "Hash",
        value: {
          a: { _class: "Integer", value: 1 },
          b: { _class: "String", value: "two" }
        }
      })
    end

    it "serializes vectors" do
      klass = Class.new do
        include Engine::Serializable
        serialize :position
        attr_reader :position
      end

      obj = klass.create(position: Vector[1.0, 2.0, 3.0])
      result = described_class.serialize(obj)

      expect(result[:position]).to eq({ _class: "Vector", value: [1.0, 2.0, 3.0] })
    end

    it "serializes matrices" do
      klass = Class.new do
        include Engine::Serializable
        serialize :transform
        attr_reader :transform
      end

      obj = klass.create(transform: Matrix[[1, 0], [0, 1]])
      result = described_class.serialize(obj)

      expect(result[:transform]).to eq({ _class: "Matrix", value: [[1, 0], [0, 1]] })
    end

    it "serializes quaternions" do
      klass = Class.new do
        include Engine::Serializable
        serialize :rotation
        attr_reader :rotation
      end

      obj = klass.create(rotation: Engine::Quaternion.new(1.0, 0.0, 0.0, 0.0))
      result = described_class.serialize(obj)

      expect(result[:rotation]).to eq({ _class: "Engine::Quaternion", value: [1.0, 0.0, 0.0, 0.0] })
    end

    it "uses serializable_data when defined on the object" do
      klass = Class.new do
        include Engine::Serializable
        attr_reader :path

        def serializable_data
          { path: @path }
        end
      end
      stub_const("TestAsset", klass)

      asset = klass.allocate
      asset.instance_variable_set(:@path, "/textures/wood.png")

      parent_klass = Class.new do
        include Engine::Serializable
        serialize :asset
        attr_reader :asset
      end

      parent = parent_klass.create(asset: asset)
      result = described_class.serialize(parent)

      expect(result[:asset]).to eq({ _class: "TestAsset", path: "/textures/wood.png" })
    end
  end

  describe ".deserialize" do
    it "reconstructs an object from a hash" do
      data = {
        _class: "TestEmpty",
        uuid: "abc-123"
      }

      result = described_class.deserialize(data)

      expect(result).to be_a(TestEmpty)
      expect(result.uuid).to eq("abc-123")
    end

    it "deserializes primitive attributes" do
      data = {
        _class: "TestSerializable",
        uuid: "xyz-789",
        name: { _class: "String", value: "Bob" },
        age: { _class: "Integer", value: 25 }
      }

      result = described_class.deserialize(data)

      expect(result.name).to eq("Bob")
      expect(result.age).to eq(25)
    end

    it "deserializes nil values" do
      data = {
        _class: "TestSerializable",
        uuid: "nil-123",
        name: nil,
        age: { _class: "NilClass", value: nil }
      }

      result = described_class.deserialize(data)

      expect(result.name).to be_nil
      expect(result.age).to be_nil
    end

    it "deserializes symbols" do
      data = {
        _class: "TestSerializable",
        uuid: "sym-123",
        name: { _class: "Symbol", value: "test_sym" },
        age: { _class: "Integer", value: 1 }
      }

      result = described_class.deserialize(data)

      expect(result.name).to eq(:test_sym)
    end

    it "deserializes arrays" do
      klass = Class.new do
        include Engine::Serializable
        serialize :items
        attr_reader :items
      end
      stub_const("TestArray", klass)
      Engine::Serializable.register_class(klass)

      data = {
        _class: "TestArray",
        uuid: "arr-123",
        items: {
          _class: "Array",
          value: [
            { _class: "Integer", value: 1 },
            { _class: "String", value: "two" }
          ]
        }
      }

      result = described_class.deserialize(data)

      expect(result.items).to eq([1, "two"])
    end

    it "deserializes hashes" do
      klass = Class.new do
        include Engine::Serializable
        serialize :data
        attr_reader :data
      end
      stub_const("TestHash", klass)
      Engine::Serializable.register_class(klass)

      data = {
        _class: "TestHash",
        uuid: "hash-123",
        data: {
          _class: "Hash",
          value: {
            a: { _class: "Integer", value: 1 },
            b: { _class: "String", value: "two" }
          }
        }
      }

      result = described_class.deserialize(data)

      expect(result.data).to eq({ a: 1, b: "two" })
    end

    it "deserializes vectors" do
      klass = Class.new do
        include Engine::Serializable
        serialize :position
        attr_reader :position
      end
      stub_const("TestVector", klass)
      Engine::Serializable.register_class(klass)

      data = {
        _class: "TestVector",
        uuid: "vec-123",
        position: { _class: "Vector", value: [1.0, 2.0, 3.0] }
      }

      result = described_class.deserialize(data)

      expect(result.position).to eq(Vector[1.0, 2.0, 3.0])
    end

    it "deserializes matrices" do
      klass = Class.new do
        include Engine::Serializable
        serialize :transform
        attr_reader :transform
      end
      stub_const("TestMatrix", klass)
      Engine::Serializable.register_class(klass)

      data = {
        _class: "TestMatrix",
        uuid: "mat-123",
        transform: { _class: "Matrix", value: [[1, 2], [3, 4]] }
      }

      result = described_class.deserialize(data)

      expect(result.transform).to eq(Matrix[[1, 2], [3, 4]])
    end

    it "deserializes quaternions" do
      klass = Class.new do
        include Engine::Serializable
        serialize :rotation
        attr_reader :rotation
      end
      stub_const("TestQuaternion", klass)
      Engine::Serializable.register_class(klass)

      data = {
        _class: "TestQuaternion",
        uuid: "quat-123",
        rotation: { _class: "Engine::Quaternion", value: [0.707, 0.707, 0.0, 0.0] }
      }

      result = described_class.deserialize(data)

      expect(result.rotation).to be_a(Engine::Quaternion)
      expect(result.rotation.w).to eq(0.707)
    end

    it "returns UnresolvedRef for references" do
      data = {
        _class: "TestWithChild",
        uuid: "parent-123",
        child: { _class: "TestEmpty", _ref: "child-uuid" }
      }

      result = described_class.deserialize(data)

      expect(result.child).to be_a(Engine::Serialization::ObjectSerializer::UnresolvedRef)
      expect(result.child.uuid).to eq("child-uuid")
      expect(result.child.class_name).to eq("TestEmpty")
    end

    it "raises error for unauthorized classes" do
      data = {
        _class: "String",
        value: "hacked"
      }

      expect {
        described_class.deserialize(data)
      }.to raise_error(Engine::Serialization::ObjectSerializer::UnauthorizedClassError)
    end

    it "uses from_serializable_data when defined" do
      klass = Class.new do
        include Engine::Serializable
        attr_reader :path

        def self.from_serializable_data(data)
          instance = allocate
          instance.instance_variable_set(:@path, data[:path])
          instance
        end
      end
      stub_const("TestAssetLoader", klass)
      Engine::Serializable.register_class(klass)

      data = { _class: "TestAssetLoader", path: "/textures/metal.png" }
      result = described_class.deserialize_value(data)

      expect(result).to be_a(klass)
      expect(result.path).to eq("/textures/metal.png")
    end

    it "does not call awake" do
      awake_called = false
      klass = Class.new do
        include Engine::Serializable
        define_method(:awake) { awake_called = true }
      end
      stub_const("TestAwake", klass)
      Engine::Serializable.register_class(klass)

      data = { _class: "TestAwake", uuid: "awake-123" }
      described_class.deserialize(data)

      expect(awake_called).to be false
    end
  end
end
