# frozen_string_literal: true

describe Engine do
  describe ".start" do
    it "starts the game engine" do
      expect(Engine::AutoLoader).to receive(:load)
      expect(Engine).to receive(:open_window)
      expect(Engine).to receive(:main_game_loop)
      expect(Engine).to receive(:terminate)

      Engine.start
    end

    it "passes opengl_version to the window" do
      allow(Engine::AutoLoader).to receive(:load)
      allow(Engine).to receive(:open_window)
      allow(Engine).to receive(:main_game_loop)
      allow(Engine).to receive(:terminate)

      Engine.start(opengl_version: "4.0")

      expect(Engine::Window.opengl_version).to eq("4.0")
    ensure
      Engine::Window.opengl_version = nil
    end
  end
end
