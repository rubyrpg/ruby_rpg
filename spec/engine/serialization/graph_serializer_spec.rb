# frozen_string_literal: true

require_relative "../../spec_helper"

class GraphTestEmpty
  include Engine::Serializable
end

class GraphTestWithRef
  include Engine::Serializable
  serialize :child
  attr_reader :child
end

class GraphTestWithArray
  include Engine::Serializable
  serialize :items
  attr_reader :items
end

class GraphTestWithHash
  include Engine::Serializable
  serialize :data
  attr_reader :data
end

class GraphTestWithAwake
  include Engine::Serializable
  serialize :name
  attr_reader :name, :awake_called

  def awake
    @awake_called = true
  end
end

describe Engine::Serialization::GraphSerializer do
  describe ".serialize" do
    it "returns an array containing the serialized root object" do
      obj = GraphTestEmpty.create
      result = described_class.serialize(obj)

      expect(result).to be_an(Array)
      expect(result.length).to eq(1)
      expect(result.first[:_class]).to eq("GraphTestEmpty")
      expect(result.first[:uuid]).to eq(obj.uuid)
    end

    it "collects referenced objects" do
      child = GraphTestEmpty.create
      parent = GraphTestWithRef.create(child: child)

      result = described_class.serialize(parent)

      expect(result.length).to eq(2)
      uuids = result.map { |h| h[:uuid] }
      expect(uuids).to contain_exactly(parent.uuid, child.uuid)
    end

    it "collects objects from arrays" do
      child1 = GraphTestEmpty.create
      child2 = GraphTestEmpty.create
      parent = GraphTestWithArray.create(items: [child1, child2])

      result = described_class.serialize(parent)

      expect(result.length).to eq(3)
      uuids = result.map { |h| h[:uuid] }
      expect(uuids).to contain_exactly(parent.uuid, child1.uuid, child2.uuid)
    end

    it "collects objects from hashes" do
      child = GraphTestEmpty.create
      parent = GraphTestWithHash.create(data: { texture: child })

      result = described_class.serialize(parent)

      expect(result.length).to eq(2)
      uuids = result.map { |h| h[:uuid] }
      expect(uuids).to contain_exactly(parent.uuid, child.uuid)
    end

    it "handles circular references without infinite loop" do
      parent = GraphTestWithRef.create
      child = GraphTestWithRef.create
      parent.instance_variable_set(:@child, child)
      child.instance_variable_set(:@child, parent)

      result = described_class.serialize(parent)

      expect(result.length).to eq(2)
    end

    it "does not duplicate objects referenced multiple times" do
      shared = GraphTestEmpty.create
      parent = GraphTestWithArray.create(items: [shared, shared])

      result = described_class.serialize(parent)

      expect(result.length).to eq(2)
    end

    it "serializes references as _ref pointers" do
      child = GraphTestEmpty.create
      parent = GraphTestWithRef.create(child: child)

      result = described_class.serialize(parent)

      parent_hash = result.find { |h| h[:uuid] == parent.uuid }
      expect(parent_hash[:child]).to eq({ _class: "GraphTestEmpty", _ref: child.uuid })
    end
  end

  describe ".deserialize" do
    it "returns an array of objects" do
      data = [
        { _class: "GraphTestEmpty", uuid: "obj-1" },
        { _class: "GraphTestEmpty", uuid: "obj-2" }
      ]

      result = described_class.deserialize(data)

      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
      expect(result.map(&:uuid)).to contain_exactly("obj-1", "obj-2")
    end

    it "resolves references between objects" do
      data = [
        { _class: "GraphTestEmpty", uuid: "child-uuid" },
        {
          _class: "GraphTestWithRef",
          uuid: "parent-uuid",
          child: { _class: "GraphTestEmpty", _ref: "child-uuid" }
        }
      ]

      result = described_class.deserialize(data)

      parent = result.find { |o| o.uuid == "parent-uuid" }
      child = result.find { |o| o.uuid == "child-uuid" }

      expect(parent.child).to eq(child)
    end

    it "resolves references inside arrays" do
      data = [
        { _class: "GraphTestEmpty", uuid: "child-uuid" },
        {
          _class: "GraphTestWithArray",
          uuid: "parent-uuid",
          items: {
            _class: "Array",
            value: [{ _class: "GraphTestEmpty", _ref: "child-uuid" }]
          }
        }
      ]

      result = described_class.deserialize(data)

      parent = result.find { |o| o.uuid == "parent-uuid" }
      child = result.find { |o| o.uuid == "child-uuid" }

      expect(parent.items.first).to eq(child)
    end

    it "resolves references inside hashes" do
      data = [
        { _class: "GraphTestEmpty", uuid: "child-uuid" },
        {
          _class: "GraphTestWithHash",
          uuid: "parent-uuid",
          data: {
            _class: "Hash",
            value: {
              texture: { _class: "GraphTestEmpty", _ref: "child-uuid" }
            }
          }
        }
      ]

      result = described_class.deserialize(data)

      parent = result.find { |o| o.uuid == "parent-uuid" }
      child = result.find { |o| o.uuid == "child-uuid" }

      expect(parent.data[:texture]).to eq(child)
    end

    it "calls awake on all objects after resolving references" do
      data = [
        {
          _class: "GraphTestWithAwake",
          uuid: "awake-uuid",
          name: { _class: "String", value: "test" }
        }
      ]

      result = described_class.deserialize(data)

      expect(result.first.awake_called).to be true
    end

    it "calls awake after references are resolved" do
      ref_during_awake = nil

      klass = Class.new do
        include Engine::Serializable
        serialize :child
        attr_reader :child

        define_method(:awake) do
          ref_during_awake = @child
        end
      end
      stub_const("GraphTestAwakeOrder", klass)
      Engine::Serializable.register_class(klass)

      data = [
        { _class: "GraphTestEmpty", uuid: "child-uuid" },
        {
          _class: "GraphTestAwakeOrder",
          uuid: "parent-uuid",
          child: { _class: "GraphTestEmpty", _ref: "child-uuid" }
        }
      ]

      result = described_class.deserialize(data)
      child = result.find { |o| o.uuid == "child-uuid" }

      expect(ref_during_awake).to eq(child)
    end
  end

  describe "round trip" do
    it "can serialize and deserialize back to equivalent objects" do
      child = GraphTestEmpty.create
      parent = GraphTestWithRef.create(child: child)

      serialized = described_class.serialize(parent)
      restored = described_class.deserialize(serialized)

      restored_parent = restored.find { |o| o.uuid == parent.uuid }
      restored_child = restored.find { |o| o.uuid == child.uuid }

      expect(restored_parent.uuid).to eq(parent.uuid)
      expect(restored_child.uuid).to eq(child.uuid)
      expect(restored_parent.child).to eq(restored_child)
    end
  end
end
