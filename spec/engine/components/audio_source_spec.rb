# frozen_string_literal: true

describe Engine::Components::AudioSource do
  describe "serialization" do
    let(:clip_path) { "assets/boom.wav" }
    let(:audio_source) do
      source = Engine::Components::AudioSource.allocate
      source.instance_variable_set(:@uuid, "test-uuid")
      source.instance_variable_set(:@clip_path, clip_path)
      source.instance_variable_set(:@radius, 500)
      source
    end

    describe "#to_serialized" do
      it "serializes clip_path and radius" do
        result = audio_source.to_serialized

        expect(result[:_class]).to eq("Engine::Components::AudioSource")
        expect(result[:clip_path]).to eq({ _class: "String", value: clip_path })
        expect(result[:radius]).to eq({ _class: "Integer", value: 500 })
      end
    end

    describe ".from_serialized" do
      it "deserializes clip_path and radius" do
        serialized = {
          _class: "Engine::Components::AudioSource",
          uuid: "test-uuid",
          clip_path: { _class: "String", value: clip_path },
          radius: { _class: "Integer", value: 500 }
        }

        result = Engine::Serializable.from_serialized(serialized)

        expect(result).to be_a(Engine::Components::AudioSource)
        expect(result.instance_variable_get(:@clip_path)).to eq(clip_path)
        expect(result.instance_variable_get(:@radius)).to eq(500)
      end
    end
  end

  describe ".create" do
    it "creates an audio source with clip_path and default radius" do
      allow(NativeAudio::Clip).to receive(:new).and_return(double("clip"))
      allow(NativeAudio::AudioSource).to receive(:new).and_return(double("source"))

      source = Engine::Components::AudioSource.create(clip_path: "test.wav")

      expect(source.instance_variable_get(:@clip_path)).to eq("test.wav")
      expect(source.instance_variable_get(:@radius)).to eq(1000)
    end

    it "creates an audio source with custom radius" do
      allow(NativeAudio::Clip).to receive(:new).and_return(double("clip"))
      allow(NativeAudio::AudioSource).to receive(:new).and_return(double("source"))

      source = Engine::Components::AudioSource.create(clip_path: "test.wav", radius: 500)

      expect(source.instance_variable_get(:@radius)).to eq(500)
    end
  end

  describe "#awake" do
    it "creates native audio resources from clip_path" do
      mock_clip = double("clip")
      mock_source = double("source")

      allow(NativeAudio::Clip).to receive(:new).with("test.wav").and_return(mock_clip)
      allow(NativeAudio::AudioSource).to receive(:new).with(mock_clip).and_return(mock_source)

      source = Engine::Components::AudioSource.allocate
      source.instance_variable_set(:@clip_path, "test.wav")
      source.instance_variable_set(:@radius, 1000)
      source.awake

      expect(source.instance_variable_get(:@source)).to eq(mock_source)
    end
  end
end
