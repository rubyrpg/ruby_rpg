# frozen_string_literal: true

describe Engine::UI::Rect do
  describe "#width" do
    it "returns the difference between right and left" do
      rect = Engine::UI::Rect.new(left: 10, right: 110, bottom: 0, top: 50)
      expect(rect.width).to eq(100)
    end
  end

  describe "#height" do
    it "returns the difference between bottom and top (Y-down)" do
      # Y-down: top < bottom, so height = bottom - top
      rect = Engine::UI::Rect.new(left: 0, right: 100, top: 20, bottom: 120)
      expect(rect.height).to eq(100)
    end
  end
end
