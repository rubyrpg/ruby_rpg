# frozen_string_literal: true

describe Engine::Components::AudioSource do
  before do
    allow(NativeAudio::Clip).to receive(:new).and_return(double("clip"))
    allow(NativeAudio::AudioSource).to receive(:new).and_return(double("source"))
  end

  describe ".create" do
    it "creates an audio source with clip_path and default radius" do
      source = Engine::Components::AudioSource.create(clip_path: "test.wav")

      expect(source.instance_variable_get(:@clip_path)).to eq("test.wav")
      expect(source.instance_variable_get(:@radius)).to eq(1000)
    end

    it "creates an audio source with custom radius" do
      source = Engine::Components::AudioSource.create(clip_path: "test.wav", radius: 500)

      expect(source.instance_variable_get(:@radius)).to eq(500)
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Components::AudioSource.create(clip_path: "assets/boom.wav", radius: 500)

      serialized = Engine::Serialization::ObjectSerializer.serialize(original)

      expect(serialized[:clip_path]).to eq({ _class: "String", value: "assets/boom.wav" })
      expect(serialized[:radius]).to eq({ _class: "Integer", value: 500 })

      restored = Engine::Serialization::ObjectSerializer.deserialize(serialized)
      restored.awake

      expect(restored.instance_variable_get(:@clip_path)).to eq("assets/boom.wav")
      expect(restored.instance_variable_get(:@radius)).to eq(500)
    end
  end
end
