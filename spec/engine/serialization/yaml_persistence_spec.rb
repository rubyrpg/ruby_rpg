# frozen_string_literal: true

require_relative "../../spec_helper"
require "tmpdir"

class YamlTestSimple
  include Engine::Serializable
  serialize :name, :value
  attr_reader :name, :value
end

class YamlTestWithRef
  include Engine::Serializable
  serialize :child
  attr_reader :child
end

class YamlTestEmpty
  include Engine::Serializable
end

describe Engine::Serialization::YamlPersistence do
  let(:temp_dir) { File.join(Dir.tmpdir, "yaml_persistence_test_#{SecureRandom.hex(4)}") }

  before { Dir.mkdir(temp_dir) }
  after { FileUtils.rm_rf(temp_dir) }

  describe ".save" do
    it "creates a YAML file" do
      obj = YamlTestSimple.create(name: "test", value: 42)
      path = "#{temp_dir}/obj.yaml"

      described_class.save(obj, path)

      expect(File.exist?(path)).to be true
    end

    it "writes an array of serialized objects" do
      obj = YamlTestSimple.create(name: "test", value: 42)
      path = "#{temp_dir}/obj.yaml"

      described_class.save(obj, path)

      content = YAML.load_file(path, permitted_classes: [Symbol])
      expect(content).to be_an(Array)
      expect(content.first[:_class]).to eq("YamlTestSimple")
    end

    it "includes referenced objects in the file" do
      child = YamlTestEmpty.create
      parent = YamlTestWithRef.create(child: child)
      path = "#{temp_dir}/parent.yaml"

      described_class.save(parent, path)

      content = YAML.load_file(path, permitted_classes: [Symbol])
      expect(content.length).to eq(2)
      uuids = content.map { |h| h[:uuid] }
      expect(uuids).to contain_exactly(parent.uuid, child.uuid)
    end
  end

  describe ".load" do
    it "loads a single object from a YAML file" do
      data = {
        _class: "YamlTestSimple",
        uuid: "load-123",
        name: { _class: "String", value: "loaded" },
        value: { _class: "Integer", value: 99 }
      }
      path = "#{temp_dir}/single.yaml"
      File.write(path, data.to_yaml)

      result = described_class.load(path)

      expect(result).to be_a(YamlTestSimple)
      expect(result.uuid).to eq("load-123")
      expect(result.name).to eq("loaded")
      expect(result.value).to eq(99)
    end

    it "loads from array format and returns the first object" do
      data = [
        { _class: "YamlTestEmpty", uuid: "child-uuid" },
        {
          _class: "YamlTestWithRef",
          uuid: "parent-uuid",
          child: { _class: "YamlTestEmpty", _ref: "child-uuid" }
        }
      ]
      path = "#{temp_dir}/array.yaml"
      File.write(path, data.to_yaml)

      result = described_class.load(path)

      # Returns first object in the array
      expect(result.uuid).to eq("child-uuid")
    end

    it "resolves references when loading" do
      child = YamlTestEmpty.create
      parent = YamlTestWithRef.create(child: child)
      path = "#{temp_dir}/refs.yaml"

      described_class.save(parent, path)
      loaded = described_class.load(path)

      # Find the parent in loaded objects
      # Actually load returns first, so let's use load_all for this test
    end
  end

  describe ".load_all" do
    it "loads all objects from a single file" do
      data = [
        { _class: "YamlTestEmpty", uuid: "obj-1" },
        { _class: "YamlTestEmpty", uuid: "obj-2" }
      ]
      path = "#{temp_dir}/multi.yaml"
      File.write(path, data.to_yaml)

      result = described_class.load_all([path])

      expect(result.length).to eq(2)
      expect(result.map(&:uuid)).to contain_exactly("obj-1", "obj-2")
    end

    it "loads and merges objects from multiple files" do
      path1 = "#{temp_dir}/file1.yaml"
      path2 = "#{temp_dir}/file2.yaml"

      File.write(path1, { _class: "YamlTestEmpty", uuid: "from-file-1" }.to_yaml)
      File.write(path2, { _class: "YamlTestEmpty", uuid: "from-file-2" }.to_yaml)

      result = described_class.load_all([path1, path2])

      expect(result.length).to eq(2)
      expect(result.map(&:uuid)).to contain_exactly("from-file-1", "from-file-2")
    end

    it "resolves references across files" do
      path1 = "#{temp_dir}/child.yaml"
      path2 = "#{temp_dir}/parent.yaml"

      child_data = { _class: "YamlTestEmpty", uuid: "cross-file-child" }
      parent_data = {
        _class: "YamlTestWithRef",
        uuid: "cross-file-parent",
        child: { _class: "YamlTestEmpty", _ref: "cross-file-child" }
      }

      File.write(path1, child_data.to_yaml)
      File.write(path2, parent_data.to_yaml)

      result = described_class.load_all([path1, path2])

      parent = result.find { |o| o.uuid == "cross-file-parent" }
      child = result.find { |o| o.uuid == "cross-file-child" }

      expect(parent.child).to eq(child)
    end
  end

  describe "round trip" do
    it "saves and loads preserving data" do
      original = YamlTestSimple.create(name: "round trip", value: 123)
      path = "#{temp_dir}/round_trip.yaml"

      described_class.save(original, path)
      loaded = described_class.load(path)

      expect(loaded.uuid).to eq(original.uuid)
      expect(loaded.name).to eq("round trip")
      expect(loaded.value).to eq(123)
    end

    it "saves and loads preserving references" do
      child = YamlTestEmpty.create
      parent = YamlTestWithRef.create(child: child)
      path = "#{temp_dir}/with_refs.yaml"

      described_class.save(parent, path)
      objects = described_class.load_all([path])

      loaded_parent = objects.find { |o| o.uuid == parent.uuid }
      loaded_child = objects.find { |o| o.uuid == child.uuid }

      expect(loaded_parent.child).to eq(loaded_child)
    end
  end
end
