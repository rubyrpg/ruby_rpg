# frozen_string_literal: true

describe "Material serialization" do
  let(:mock_shader) do
    shader = Engine::Shader.allocate
    shader.instance_variable_set(:@vertex_path, "./shaders/test_vertex.glsl")
    shader.instance_variable_set(:@fragment_path, "./shaders/test_frag.glsl")
    shader
  end

  let(:mock_texture) do
    texture = Engine::Texture.allocate
    texture.instance_variable_set(:@relative_path, "textures/test.png")
    texture.instance_variable_set(:@flip, false)
    texture
  end

  let(:mock_material) do
    material = Engine::Material.allocate
    material.instance_variable_set(:@shader, mock_shader)
    material.instance_variable_set(:@floats, { "roughness" => 0.5 })
    material.instance_variable_set(:@ints, { "mode" => 1 })
    material.instance_variable_set(:@vec3s, { "baseColour" => Vector[1.0, 0.5, 0.0] })
    material.instance_variable_set(:@textures, { "image" => mock_texture })
    material
  end

  describe "#to_serialized" do
    it "serializes all material attributes" do
      result = Engine::Serialization::ObjectSerializer.serialize(mock_material)

      expect(result[:_class]).to eq("Engine::Material")
      expect(result[:uuid]).to be_a(String)
    end

    it "serializes the shader using custom hooks" do
      result = Engine::Serialization::ObjectSerializer.serialize(mock_material)

      expect(result[:shader][:_class]).to eq("Engine::Shader")
      expect(result[:shader][:vertex_path]).to eq("./shaders/test_vertex.glsl")
      expect(result[:shader]).not_to have_key(:_ref)
    end

    it "serializes textures using custom hooks" do
      result = Engine::Serialization::ObjectSerializer.serialize(mock_material)

      expect(result[:textures][:_class]).to eq("Hash")
      expect(result[:textures][:value]["image"][:_class]).to eq("Engine::Texture")
      expect(result[:textures][:value]["image"][:path]).to eq("textures/test.png")
    end

    it "serializes floats hash" do
      result = Engine::Serialization::ObjectSerializer.serialize(mock_material)

      expect(result[:floats][:_class]).to eq("Hash")
      expect(result[:floats][:value]["roughness"]).to eq({ _class: "Float", value: 0.5 })
    end

    it "serializes vec3s with Vector type" do
      result = Engine::Serialization::ObjectSerializer.serialize(mock_material)

      expect(result[:vec3s][:_class]).to eq("Hash")
      expect(result[:vec3s][:value]["baseColour"]).to eq({ _class: "Vector", value: [1.0, 0.5, 0.0] })
    end
  end
end
