# frozen_string_literal: true

describe Engine::Mesh do
  describe "serialization" do
    it "serializes mesh_file and source attributes" do
      mesh = Engine::Mesh.from_engine("cube")

      serialized = Engine::Serialization::ObjectSerializer.serialize(mesh)

      expect(serialized[:_class]).to eq("Engine::Mesh")
      expect(serialized[:mesh_file]).to eq({ _class: "String", value: "cube" })
      expect(serialized[:source]).to eq({ _class: "Symbol", value: "engine" })
    end

    it "deserializes and reconstructs base_path from attributes" do
      mesh = Engine::Mesh.from_engine("cube")
      serialized = Engine::Serialization::ObjectSerializer.serialize(mesh)

      restored = Engine::Serialization::ObjectSerializer.deserialize(serialized)
      restored.awake

      expect(restored.mesh_file).to eq("cube")
      expect(restored.source).to eq(:engine)
    end

    it "shares vertex_data cache across instances" do
      mesh1 = Engine::Mesh.from_engine("cube")
      mesh2 = Engine::Mesh.create(mesh_file: "cube", source: :engine)

      # Access vertex_data to trigger memoization
      data1 = mesh1.vertex_data
      data2 = mesh2.vertex_data

      # Same cached array from class-level cache
      expect(data1).to be(data2)
    end

    it "shares index_data cache across instances" do
      mesh1 = Engine::Mesh.from_engine("cube")
      mesh2 = Engine::Mesh.create(mesh_file: "cube", source: :engine)

      data1 = mesh1.index_data
      data2 = mesh2.index_data

      expect(data1).to be(data2)
    end
  end

  describe "factory methods with caching" do
    it "caches mesh instances from from_engine" do
      mesh1 = Engine::Mesh.from_engine("cube")
      mesh2 = Engine::Mesh.from_engine("cube")

      expect(mesh1).to be(mesh2)
    end

    it "caches mesh instances from for" do
      mesh_file = "test_mesh_#{SecureRandom.hex(4)}"
      base_path = File.join(GAME_DIR, "_imported", mesh_file)

      FileUtils.mkdir_p(File.dirname(base_path))
      File.write("#{base_path}.vertex_data", "1.0\n2.0\n3.0\n")
      File.write("#{base_path}.index_data", "0\n1\n2\n")

      begin
        mesh1 = Engine::Mesh.for(mesh_file)
        mesh2 = Engine::Mesh.for(mesh_file)

        expect(mesh1).to be(mesh2)
      ensure
        File.delete("#{base_path}.vertex_data") if File.exist?("#{base_path}.vertex_data")
        File.delete("#{base_path}.index_data") if File.exist?("#{base_path}.index_data")
        Engine::Mesh.mesh_cache.delete(base_path)
      end
    end
  end

  describe "round-trip serialization" do
    it "can serialize and deserialize a mesh" do
      original = Engine::Mesh.from_engine("cube")

      serialized = Engine::Serialization::ObjectSerializer.serialize(original)
      restored = Engine::Serialization::ObjectSerializer.deserialize(serialized)
      restored.awake

      expect(restored.mesh_file).to eq(original.mesh_file)
      expect(restored.source).to eq(original.source)
      expect(restored.vertex_data).to eq(original.vertex_data)
      expect(restored.index_data).to eq(original.index_data)
    end

    it "uses GraphSerializer to serialize mesh with parent object" do
      wrapper_class = Class.new do
        include Engine::Serializable
        serialize :mesh
        attr_reader :mesh
      end
      stub_const("MeshWrapper", wrapper_class)
      Engine::Serializable.register_class(wrapper_class)

      mesh = Engine::Mesh.from_engine("cube")
      wrapper = wrapper_class.create(mesh: mesh)

      serialized = Engine::Serialization::GraphSerializer.serialize(wrapper)
      restored = Engine::Serialization::GraphSerializer.deserialize(serialized)

      restored_wrapper = restored.find { |o| o.is_a?(wrapper_class) }
      expect(restored_wrapper.mesh.mesh_file).to eq("cube")
      expect(restored_wrapper.mesh.source).to eq(:engine)
    end
  end
end
