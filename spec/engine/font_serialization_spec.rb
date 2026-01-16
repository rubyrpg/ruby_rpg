# frozen_string_literal: true

describe Engine::Font do
  describe ".create" do
    it "creates a font with the given path" do
      font = Engine::Font.create(font_file_path: "fonts/arial.ttf")

      expect(font).to be_a(Engine::Font)
      expect(font.instance_variable_get(:@font_file_path)).to eq("fonts/arial.ttf")
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Font.create(font_file_path: "fonts/arial.ttf")

      serialized = Engine::Serialization::ObjectSerializer.serialize(original)

      expect(serialized[:font_file_path]).to eq({ _class: "String", value: "fonts/arial.ttf" })

      restored = Engine::Serialization::ObjectSerializer.deserialize(serialized)
      restored.awake

      expect(restored.instance_variable_get(:@font_file_path)).to eq("fonts/arial.ttf")
    end
  end
end
