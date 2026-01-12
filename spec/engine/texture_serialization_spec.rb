# frozen_string_literal: true

describe "Texture serialization" do
  let(:mock_texture) do
    # Create a texture-like object without OpenGL
    texture = Engine::Texture.allocate
    texture.instance_variable_set(:@relative_path, "textures/wood.png")
    texture.instance_variable_set(:@flip, true)
    texture
  end

  describe "#serializable_data" do
    it "returns the relative path and flip flag" do
      expect(mock_texture.serializable_data).to eq({
        path: "textures/wood.png",
        flip: true
      })
    end
  end

  describe "serialization round-trip" do
    it "serializes texture as custom data instead of UUID reference" do
      wrapper_class = Class.new do
        include Engine::Serializable
        serialize :texture
        attr_reader :texture
      end

      wrapper = wrapper_class.create(texture: mock_texture)
      result = wrapper.to_serialized

      expect(result[:texture][:_class]).to eq("Engine::Texture")
      expect(result[:texture][:path]).to eq("textures/wood.png")
      expect(result[:texture][:flip]).to eq(true)
      expect(result[:texture]).not_to have_key(:_ref)
    end
  end
end
