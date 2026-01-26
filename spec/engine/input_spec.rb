# frozen_string_literal: true

describe Engine::Input do
  before do
    Engine::Input.instance_variable_set(:@keys, nil)
  end

  describe ".key?" do
    it "returns false when the key is not pressed" do
      expect(Engine::Input.key?(Engine::Input::KEY_A)).to eq(false)
    end

    it "returns true when the key is pressed" do
      Engine::Input._on_key_down(Engine::Input::KEY_A)
      expect(Engine::Input.key?(Engine::Input::KEY_A)).to eq(true)
    end

    it "returns true when the key is held" do
      Engine::Input._on_key_down(Engine::Input::KEY_A)
      Engine::Input.update_key_states
      expect(Engine::Input.key?(Engine::Input::KEY_A)).to eq(true)
    end
  end

  describe ".key_down?" do
    it "returns false when the key is not pressed" do
      expect(Engine::Input.key_down?(Engine::Input::KEY_A)).to eq(false)
    end

    it "returns true when the key is pressed during the first frame" do
      Engine::Input._on_key_down(Engine::Input::KEY_A)
      expect(Engine::Input.key_down?(Engine::Input::KEY_A)).to eq(true)
    end

    it "returns false when the key is held" do
      Engine::Input._on_key_down(Engine::Input::KEY_A)
      Engine::Input.update_key_states
      expect(Engine::Input.key_down?(Engine::Input::KEY_A)).to eq(false)
    end
  end

  describe ".key_up?" do
    it "returns false when the key is not pressed" do
      expect(Engine::Input.key_up?(Engine::Input::KEY_A)).to eq(false)
    end

    it "returns true when the key is released" do
      Engine::Input._on_key_up(Engine::Input::KEY_A)
      expect(Engine::Input.key_up?(Engine::Input::KEY_A)).to eq(true)
    end
  end

  describe ".key_callback" do
    it "calls _on_key_down when the action is Engine::Input::PRESS" do
      expect(Engine::Input).to receive(:_on_key_down).with(Engine::Input::KEY_A)
      Engine::Input.key_callback(Engine::Input::KEY_A, Engine::Input::PRESS)
    end

    it "calls _on_key_up when the action is Engine::Input::RELEASE" do
      expect(Engine::Input).to receive(:_on_key_up).with(Engine::Input::KEY_A)
      Engine::Input.key_callback(Engine::Input::KEY_A, Engine::Input::RELEASE)
    end
  end
end
