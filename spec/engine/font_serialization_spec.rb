# frozen_string_literal: true

describe Engine::Font do
  describe ".for" do
    it "creates a font with the given path and caches it" do
      font1 = Engine::Font.for("fonts/arial.ttf")
      font2 = Engine::Font.for("fonts/arial.ttf")

      expect(font1).to be_a(Engine::Font)
      expect(font1.font_file_path).to eq("fonts/arial.ttf")
      expect(font1.source).to eq(:game)
      expect(font1).to be(font2)
    end

    it "supports engine source" do
      font = Engine::Font.for("fonts/arial.ttf", source: :engine)

      expect(font.source).to eq(:engine)
    end
  end

  describe ".create" do
    it "creates a font with the given path" do
      font = Engine::Font.create(font_file_path: "fonts/arial.ttf", source: :game)

      expect(font).to be_a(Engine::Font)
      expect(font.font_file_path).to eq("fonts/arial.ttf")
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly when nested in another object" do
      wrapper_class = Class.new do
        include Engine::Serializable
        serialize :font
        attr_reader :font
      end
      stub_const("FontWrapper", wrapper_class)
      Engine::Serializable.register_class(wrapper_class)

      font = Engine::Font.create(font_file_path: "fonts/arial.ttf", source: :game)
      wrapper = wrapper_class.create(font: font)

      serialized = Engine::Serialization::ObjectSerializer.serialize(wrapper)

      expect(serialized[:font][:_class]).to eq("Engine::Font")
      expect(serialized[:font][:font_file_path]).to eq("fonts/arial.ttf")
      expect(serialized[:font][:source]).to eq(:game)
      expect(serialized[:font]).not_to have_key(:_ref)

      restored = Engine::Serialization::GraphSerializer.deserialize([serialized])
      restored_wrapper = restored.first

      expect(restored_wrapper.font.font_file_path).to eq("fonts/arial.ttf")
      expect(restored_wrapper.font.source).to eq(:game)
    end
  end
end
