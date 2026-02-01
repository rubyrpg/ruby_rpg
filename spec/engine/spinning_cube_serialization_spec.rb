# frozen_string_literal: true

require "tmpdir"
require_relative "../../samples/cubes/components/spinner"

describe "Spinning cube serialization" do
  let(:mock_shader) do
    shader = Engine::Shader.allocate
    shader.instance_variable_set(:@uuid, SecureRandom.uuid)
    shader.instance_variable_set(:@vertex_path, "./shaders/mesh_vertex.glsl")
    shader.instance_variable_set(:@fragment_path, "./shaders/mesh_frag.glsl")
    shader
  end

  let(:mock_material) do
    material = Engine::Material.allocate
    material.instance_variable_set(:@uuid, SecureRandom.uuid)
    material.instance_variable_set(:@shader, mock_shader)
    material.instance_variable_set(:@floats, {})
    material.instance_variable_set(:@ints, {})
    material.instance_variable_set(:@vec2s, {})
    material.instance_variable_set(:@vec3s, {})
    material.instance_variable_set(:@vec4s, {})
    material.instance_variable_set(:@mat4s, {})
    material.instance_variable_set(:@textures, {})
    material
  end

  before do
    allow(Engine::StandardObjects).to receive(:default_material).and_return(mock_material)
    allow(Rendering::RenderPipeline).to receive(:add_instance)
    allow(Rendering::RenderPipeline).to receive(:update_instance)
    allow(Rendering::RenderPipeline).to receive(:remove_instance)
    allow(Engine::GameObject).to receive(:register_renderers)

    # Stub shader factory to avoid OpenGL calls during deserialization
    allow(Engine::Shader).to receive(:from_serializable_data) do |data|
      shader = Engine::Shader.allocate
      shader.instance_variable_set(:@uuid, SecureRandom.uuid)
      shader.instance_variable_set(:@vertex_path, data[:vertex_path])
      shader.instance_variable_set(:@fragment_path, data[:fragment_path])
      shader
    end
  end

  it "can serialize and deserialize a spinning cube" do
    # Create a spinning cube like in the cubes sample
    cube = Engine::StandardObjects::Cube.create(
      pos: Vector[25, 20, -30],
      scale: Vector[16, 16, 16],
      components: [Cubes::Spinner.create(speed: 45)]
    )

    # Serialize the entire object graph
    serialized = Engine::Serialization::GraphSerializer.serialize(cube)

    # Check what got serialized
    class_names = serialized.map { |h| h[:_class] }
    expect(class_names).to include("Engine::GameObject")
    expect(class_names).to include("Engine::Components::MeshRenderer")
    expect(class_names).to include("Cubes::Spinner")
    expect(class_names).to include("Engine::Material")
    # Mesh is now inlined in MeshRenderer, not a separate object
    expect(class_names).not_to include("Engine::Mesh")

    # Deserialize
    restored_objects = Engine::Serialization::GraphSerializer.deserialize(serialized)

    # Find the restored cube
    restored_cube = restored_objects.find { |o| o.is_a?(Engine::GameObject) && o.name == "Cube" }

    expect(restored_cube).not_to be_nil
    expect(restored_cube.pos).to eq(Vector[25, 20, -30])
    expect(restored_cube.scale).to eq(Vector[16, 16, 16])

    # Check spinner component
    spinner = restored_cube.components.find { |c| c.is_a?(Cubes::Spinner) }
    expect(spinner).not_to be_nil
    expect(spinner.instance_variable_get(:@speed)).to eq(45)

    # Check mesh renderer
    mesh_renderer = restored_cube.renderers.find { |c| c.is_a?(Engine::Components::MeshRenderer) }
    expect(mesh_renderer).not_to be_nil
    expect(mesh_renderer.mesh.mesh_file).to eq("cube")
    expect(mesh_renderer.mesh.source).to eq(:engine)
  end

  it "can save and load from a YAML file" do
    cube = Engine::StandardObjects::Cube.create(
      pos: Vector[10, 20, 30],
      scale: Vector[2, 2, 2],
      components: [Cubes::Spinner.create(speed: 90)]
    )

    temp_file = File.join(Dir.tmpdir, "spinning_cube_#{SecureRandom.hex(4)}.yaml")

    begin
      Engine::Serialization::YamlPersistence.save(cube, temp_file)

      expect(File.exist?(temp_file)).to be true

      # Load all objects from file
      restored_objects = Engine::Serialization::YamlPersistence.load_all([temp_file])
      restored_cube = restored_objects.find { |o| o.is_a?(Engine::GameObject) }

      expect(restored_cube.pos).to eq(Vector[10, 20, 30])
      expect(restored_cube.scale).to eq(Vector[2, 2, 2])

      spinner = restored_cube.components.find { |c| c.is_a?(Cubes::Spinner) }
      expect(spinner.instance_variable_get(:@speed)).to eq(90)
    ensure
      File.delete(temp_file) if File.exist?(temp_file)
    end
  end
end
