# frozen_string_literal: true

describe Engine::Components::FontRendererBase do
  let(:mock_texture) { double("texture", texture: 123) }
  let(:mock_font) do
    font = Engine::Font.allocate
    font.instance_variable_set(:@uuid, "test-font-uuid")
    font.instance_variable_set(:@font_file_path, "assets/arial.ttf")
    font.instance_variable_set(:@source, :game)
    allow(font).to receive(:texture).and_return(mock_texture)
    font
  end

  describe ".create" do
    it "creates a font renderer with font and string" do
      renderer = Engine::Components::FontRendererBase.create(
        font: mock_font,
        string: "Hello"
      )

      expect(renderer.instance_variable_get(:@font)).to eq(mock_font)
      expect(renderer.instance_variable_get(:@string)).to eq("Hello")
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Components::FontRendererBase.create(
        font: mock_font,
        string: "Hello World"
      )

      serialized = Engine::Serialization::ObjectSerializer.serialize(original)

      expect(serialized[:string]).to eq({ _class: "String", value: "Hello World" })
      # Font is now serialized inline with its data (like Mesh, Texture, Shader)
      expect(serialized[:font][:_class]).to eq("Engine::Font")
      expect(serialized[:font][:font_file_path]).to eq("assets/arial.ttf")
      expect(serialized[:font][:source]).to eq(:game)
    end
  end
end
