# frozen_string_literal: true

describe "Shader serialization" do
  let(:mock_shader) do
    # Create a shader-like object without OpenGL
    shader = Engine::Shader.allocate
    shader.instance_variable_set(:@vertex_path, "./shaders/test_vertex.glsl")
    shader.instance_variable_set(:@fragment_path, "./shaders/test_frag.glsl")
    shader
  end

  describe "#serializable_data" do
    it "returns the shader paths" do
      expect(mock_shader.serializable_data).to eq({
        vertex_path: "./shaders/test_vertex.glsl",
        fragment_path: "./shaders/test_frag.glsl"
      })
    end
  end

  describe "serialization round-trip" do
    it "serializes shader as custom data instead of UUID reference" do
      wrapper_class = Class.new do
        include Engine::Serializable
        serialize :shader
        attr_reader :shader
      end

      wrapper = wrapper_class.create(shader: mock_shader)
      result = wrapper.to_serialized

      expect(result[:shader][:_class]).to eq("Engine::Shader")
      expect(result[:shader][:vertex_path]).to eq("./shaders/test_vertex.glsl")
      expect(result[:shader][:fragment_path]).to eq("./shaders/test_frag.glsl")
      expect(result[:shader]).not_to have_key(:_ref)
    end
  end
end
