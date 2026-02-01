# frozen_string_literal: true

require "tmpdir"

describe "Material file loading" do
  let(:temp_file) { File.join(Dir.tmpdir, "test_material_#{SecureRandom.hex(4)}.mat") }

  after { File.delete(temp_file) if File.exist?(temp_file) }

  it "loads a material from a YAML file" do
    # Stub Shader.from_serializable_data to avoid OpenGL
    mock_shader = Engine::Shader.allocate
    mock_shader.instance_variable_set(:@vertex_path, "./shaders/colour_vertex.glsl")
    mock_shader.instance_variable_set(:@fragment_path, "./shaders/colour_frag.glsl")
    allow(Engine::Shader).to receive(:from_serializable_data).and_return(mock_shader)

    yaml_content = <<~YAML
      ---
      :_class: Engine::Material
      :uuid: test-material-001
      :shader:
        :_class: Engine::Shader
        :vertex_path: "./shaders/colour_vertex.glsl"
        :fragment_path: "./shaders/colour_frag.glsl"
      :floats:
        :_class: Hash
        :value:
          roughness:
            :_class: Float
            :value: 0.8
      :ints:
        :_class: Hash
        :value: {}
      :vec2s:
        :_class: Hash
        :value: {}
      :vec3s:
        :_class: Hash
        :value:
          colour:
            :_class: Vector
            :value:
              - 1.0
              - 2.0
              - 3.0
      :vec4s:
        :_class: Hash
        :value: {}
      :mat4s:
        :_class: Hash
        :value: {}
      :textures:
        :_class: Hash
        :value: {}
    YAML

    File.write(temp_file, yaml_content)

    material = Engine::Serialization::YamlPersistence.load(temp_file)

    expect(material).to be_a(Engine::Material)
    expect(material.uuid).to eq("test-material-001")
    expect(material.shader).to eq(mock_shader)
    expect(material.send(:floats)).to eq({ "roughness" => 0.8 })
    expect(material.send(:vec3s)).to eq({ "colour" => Vector[1.0, 2.0, 3.0] })
  end
end
