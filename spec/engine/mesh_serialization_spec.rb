# frozen_string_literal: true

describe Engine::Mesh do
  describe "serialization" do
    it "returns serializable_data with mesh_file and source" do
      mesh = Engine::Mesh.from_engine("cube")

      expect(mesh.serializable_data).to eq({
        mesh_file: "cube",
        source: :engine
      })
    end

    it "reconstructs mesh from serializable_data via from_serializable_data" do
      data = { mesh_file: "cube", source: :engine }

      restored = Engine::Mesh.from_serializable_data(data)

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
    it "serializes mesh inline when contained in another object" do
      wrapper_class = Class.new do
        include Engine::Serializable
        serialize :mesh
        attr_reader :mesh
      end
      stub_const("MeshWrapper", wrapper_class)
      Engine::Serializable.register_class(wrapper_class)

      mesh = Engine::Mesh.from_engine("cube")
      wrapper = wrapper_class.create(mesh: mesh)
      result = Engine::Serialization::ObjectSerializer.serialize(wrapper)

      expect(result[:mesh][:_class]).to eq("Engine::Mesh")
      expect(result[:mesh][:mesh_file]).to eq("cube")
      expect(result[:mesh][:source]).to eq(:engine)
      expect(result[:mesh]).not_to have_key(:_ref)
    end

    it "uses GraphSerializer to serialize mesh inline with parent object" do
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

      # Mesh should be inlined, not a separate object in the graph
      expect(serialized.length).to eq(1)
      expect(serialized.first[:mesh][:_class]).to eq("Engine::Mesh")
      expect(serialized.first[:mesh][:mesh_file]).to eq("cube")

      restored = Engine::Serialization::GraphSerializer.deserialize(serialized)

      # Only the wrapper should be in the restored array (mesh is inlined)
      expect(restored.length).to eq(1)
      restored_wrapper = restored.first
      expect(restored_wrapper.mesh.mesh_file).to eq("cube")
      expect(restored_wrapper.mesh.source).to eq(:engine)
    end
  end
end
