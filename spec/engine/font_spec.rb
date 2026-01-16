# frozen_string_literal: true

describe Engine::Font do
  describe "#string_indices" do
    it "returns the indices of the string" do
      font = Engine::Font.create(font_file_path:"spec/fixtures/UbuntuMono-R.ttf")

      expect(font.string_indices("Hello")).to eq([71, 100, 107, 107, 110])
    end
  end

  describe "#string_offsets" do
    let(:widths) do
      {
        "71" => {"width" => 100 }, # H
        "100" => { "width" => 80 }, # e
        "107" => { "width" => 30 }, # l
        "110" => { "width" => 50 }, # o
        "118" => { "width" => 100 }, # w
        "113" => { "width" => 60 }, # r
        "99" => { "width" => 60 } # d
      }
    end
    before do
      stub_const("GAME_DIR", "spec")
    end

    it "returns the offsets of the string" do
      allow(File).to receive(:read).and_return(JSON.dump(widths))
      font = Engine::Font.create(font_file_path:"spec/fixtures/UbuntuMono-R.ttf")

      expect(font.string_offsets("Hello\nworld"))
        .to eq([
                 [0.0, 0.0], [1.46484375, 0.0], [2.63671875, 0.0], [3.076171875, 0.0], [3.515625, 0.0],
                 [0.0, -1.0], [1.46484375, -1.0], [2.197265625, -1.0], [3.076171875, -1.0], [3.515625, -1.0]
               ]
            )
    end
  end
end
