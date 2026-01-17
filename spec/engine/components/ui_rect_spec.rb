# frozen_string_literal: true

describe Engine::Components::UIRect do
  before do
    allow(Engine::Window).to receive(:framebuffer_width).and_return(800)
    allow(Engine::Window).to receive(:framebuffer_height).and_return(600)
  end

  describe ".create" do
    it "creates a UIRect with default values that fill the parent" do
      rect = Engine::Components::UIRect.create
      rect.awake

      expect(rect.left_ratio).to eq(0.0)
      expect(rect.right_ratio).to eq(0.0)
      expect(rect.bottom_ratio).to eq(0.0)
      expect(rect.top_ratio).to eq(0.0)
      expect(rect.left_offset).to eq(0)
      expect(rect.right_offset).to eq(0)
      expect(rect.bottom_offset).to eq(0)
      expect(rect.top_offset).to eq(0)
    end

    it "creates a UIRect with custom ratios" do
      rect = Engine::Components::UIRect.create(
        left_ratio: 0.25,
        right_ratio: 0.75,
        bottom_ratio: 0.1,
        top_ratio: 0.9
      )
      rect.awake

      expect(rect.left_ratio).to eq(0.25)
      expect(rect.right_ratio).to eq(0.75)
      expect(rect.bottom_ratio).to eq(0.1)
      expect(rect.top_ratio).to eq(0.9)
    end
  end

  describe "#computed_rect" do
    context "with no parent" do
      it "computes rect relative to screen" do
        game_object = Engine::GameObject.create(
          name: "Test",
          components: [Engine::Components::UIRect.create(
            left_ratio: 0.0,
            right_ratio: 0.5,
            bottom_ratio: 0.0,
            top_ratio: 0.5
          )]
        )
        ui_rect = game_object.components.first
        ui_rect.awake

        computed = ui_rect.computed_rect

        expect(computed.left).to eq(0)
        expect(computed.right).to eq(400)
        expect(computed.bottom).to eq(0)
        expect(computed.top).to eq(300)
      end

      it "applies pixel offsets" do
        game_object = Engine::GameObject.create(
          name: "Test",
          components: [Engine::Components::UIRect.create(
            left_offset: 10,
            right_offset: 10,
            bottom_offset: 20,
            top_offset: 20
          )]
        )
        ui_rect = game_object.components.first
        ui_rect.awake

        computed = ui_rect.computed_rect

        expect(computed.left).to eq(10)
        expect(computed.right).to eq(790)
        expect(computed.bottom).to eq(20)
        expect(computed.top).to eq(580)
      end
    end

    context "with a parent UIRect" do
      it "computes rect relative to parent" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [Engine::Components::UIRect.create(
            left_ratio: 0.0,
            right_ratio: 0.5,
            bottom_ratio: 0.0,
            top_ratio: 0.5
          )]
        )
        parent.components.first.awake

        child = Engine::GameObject.create(
          name: "Child",
          parent: parent,
          components: [Engine::Components::UIRect.create(
            left_ratio: 0.0,
            right_ratio: 0.5,
            bottom_ratio: 0.0,
            top_ratio: 0.5
          )]
        )
        child_rect = child.components.first
        child_rect.awake

        computed = child_rect.computed_rect

        # Parent is 0-400 x 0-300, child is half of that
        expect(computed.left).to eq(0)
        expect(computed.right).to eq(200)
        expect(computed.bottom).to eq(0)
        expect(computed.top).to eq(150)
      end

      it "applies offsets within parent bounds" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [Engine::Components::UIRect.create(
            left_ratio: 0.25,
            right_ratio: 0.25,
            bottom_ratio: 0.25,
            top_ratio: 0.25
          )]
        )
        parent.components.first.awake

        child = Engine::GameObject.create(
          name: "Child",
          parent: parent,
          components: [Engine::Components::UIRect.create(
            left_offset: 10,
            right_offset: 10,
            bottom_offset: 10,
            top_offset: 10
          )]
        )
        child_rect = child.components.first
        child_rect.awake

        computed = child_rect.computed_rect

        # Parent is 200-600 x 150-450
        expect(computed.left).to eq(210)
        expect(computed.right).to eq(590)
        expect(computed.bottom).to eq(160)
        expect(computed.top).to eq(440)
      end
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Components::UIRect.create(
        left_ratio: 0.1,
        right_ratio: 0.9,
        bottom_ratio: 0.2,
        top_ratio: 0.8,
        left_offset: 5,
        right_offset: -5,
        bottom_offset: 10,
        top_offset: -10
      )

      serialized = Engine::Serialization::ObjectSerializer.serialize(original)

      expect(serialized[:left_ratio]).to eq({ _class: "Float", value: 0.1 })
      expect(serialized[:right_ratio]).to eq({ _class: "Float", value: 0.9 })
      expect(serialized[:bottom_ratio]).to eq({ _class: "Float", value: 0.2 })
      expect(serialized[:top_ratio]).to eq({ _class: "Float", value: 0.8 })
      expect(serialized[:left_offset]).to eq({ _class: "Integer", value: 5 })
      expect(serialized[:right_offset]).to eq({ _class: "Integer", value: -5 })
      expect(serialized[:bottom_offset]).to eq({ _class: "Integer", value: 10 })
      expect(serialized[:top_offset]).to eq({ _class: "Integer", value: -10 })
    end
  end
end
