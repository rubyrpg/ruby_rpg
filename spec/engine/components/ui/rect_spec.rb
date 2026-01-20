# frozen_string_literal: true

describe Engine::Components::UI::Rect do
  before do
    allow(Engine::Window).to receive(:framebuffer_width).and_return(800)
    allow(Engine::Window).to receive(:framebuffer_height).and_return(600)
    Engine::Components::UI::Rect.rects.clear
  end

  describe ".create" do
    it "creates a Rect with default values that fill the parent" do
      rect = Engine::Components::UI::Rect.create
      rect.awake

      expect(rect.left_ratio).to eq(0.0)
      expect(rect.right_ratio).to eq(0.0)
      expect(rect.bottom_ratio).to eq(0.0)
      expect(rect.top_ratio).to eq(0.0)
      expect(rect.left_offset).to eq(0)
      expect(rect.right_offset).to eq(0)
      expect(rect.bottom_offset).to eq(0)
      expect(rect.top_offset).to eq(0)
      expect(rect.mask).to eq(false)
    end

    it "creates a Rect with mask enabled" do
      rect = Engine::Components::UI::Rect.create(mask: true)
      rect.awake

      expect(rect.mask).to eq(true)
    end

    it "creates a Rect with custom ratios" do
      rect = Engine::Components::UI::Rect.create(
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
          components: [Engine::Components::UI::Rect.create(
            left_ratio: 0.0,
            right_ratio: 0.5,
            bottom_ratio: 0.0,
            top_ratio: 0.5
          )]
        )
        ui_rect = game_object.components.first
        ui_rect.awake

        computed = ui_rect.computed_rect

        # Y-down: top=0 at screen top, bottom=600 at screen bottom
        # top_ratio=0.5 means top edge is 50% down from screen top
        expect(computed.left).to eq(0)
        expect(computed.right).to eq(400)
        expect(computed.top).to eq(300)
        expect(computed.bottom).to eq(600)
      end

      it "applies pixel offsets" do
        game_object = Engine::GameObject.create(
          name: "Test",
          components: [Engine::Components::UI::Rect.create(
            left_offset: 10,
            right_offset: 10,
            bottom_offset: 20,
            top_offset: 20
          )]
        )
        ui_rect = game_object.components.first
        ui_rect.awake

        computed = ui_rect.computed_rect

        # Y-down: top_offset pushes top edge down, bottom_offset pushes bottom edge up
        expect(computed.left).to eq(10)
        expect(computed.right).to eq(790)
        expect(computed.top).to eq(20)
        expect(computed.bottom).to eq(580)
      end
    end

    context "with a parent Rect" do
      it "computes rect relative to parent" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [Engine::Components::UI::Rect.create(
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
          components: [Engine::Components::UI::Rect.create(
            left_ratio: 0.0,
            right_ratio: 0.5,
            bottom_ratio: 0.0,
            top_ratio: 0.5
          )]
        )
        child_rect = child.components.first
        child_rect.awake

        computed = child_rect.computed_rect

        # Y-down: Parent is 0-400 x 300-600 (top=300, bottom=600)
        # Child is half of parent, so 0-200 x 450-600
        expect(computed.left).to eq(0)
        expect(computed.right).to eq(200)
        expect(computed.top).to eq(450)
        expect(computed.bottom).to eq(600)
      end

      it "applies offsets within parent bounds" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [Engine::Components::UI::Rect.create(
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
          components: [Engine::Components::UI::Rect.create(
            left_offset: 10,
            right_offset: 10,
            bottom_offset: 10,
            top_offset: 10
          )]
        )
        child_rect = child.components.first
        child_rect.awake

        computed = child_rect.computed_rect

        # Y-down: Parent is 200-600 x 150-450 (top=150, bottom=450)
        # Child with 10px offsets: 210-590 x 160-440
        expect(computed.left).to eq(210)
        expect(computed.right).to eq(590)
        expect(computed.top).to eq(160)
        expect(computed.bottom).to eq(440)
      end
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Components::UI::Rect.create(
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

  describe "#z_layer" do
    context "with no parent" do
      it "defaults to 0" do
        game_object = Engine::GameObject.create(
          name: "Test",
          components: [Engine::Components::UI::Rect.create]
        )
        rect = game_object.components.first

        expect(rect.z_layer).to eq(0)
      end

      it "can be explicitly set" do
        game_object = Engine::GameObject.create(
          name: "Test",
          components: [Engine::Components::UI::Rect.create(z_layer: 10)]
        )
        rect = game_object.components.first

        expect(rect.z_layer).to eq(10)
      end
    end

    context "with a parent" do
      it "inherits parent z_layer + 10" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [Engine::Components::UI::Rect.create(z_layer: 5)]
        )

        child = Engine::GameObject.create(
          name: "Child",
          parent: parent,
          components: [Engine::Components::UI::Rect.create]
        )
        child_rect = child.components.first

        expect(child_rect.z_layer).to eq(15)
      end

      it "chains inheritance through multiple levels" do
        grandparent = Engine::GameObject.create(
          name: "Grandparent",
          components: [Engine::Components::UI::Rect.create(z_layer: 10)]
        )

        parent = Engine::GameObject.create(
          name: "Parent",
          parent: grandparent,
          components: [Engine::Components::UI::Rect.create]
        )

        child = Engine::GameObject.create(
          name: "Child",
          parent: parent,
          components: [Engine::Components::UI::Rect.create]
        )
        child_rect = child.components.first

        expect(child_rect.z_layer).to eq(30)
      end

      it "explicit z_layer overrides inheritance" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [Engine::Components::UI::Rect.create(z_layer: 100)]
        )

        child = Engine::GameObject.create(
          name: "Child",
          parent: parent,
          components: [Engine::Components::UI::Rect.create(z_layer: 5)]
        )
        child_rect = child.components.first

        expect(child_rect.z_layer).to eq(5)
      end
    end

    describe "#z_layer=" do
      it "updates the z_layer value" do
        game_object = Engine::GameObject.create(
          name: "Test",
          components: [Engine::Components::UI::Rect.create(z_layer: 10)]
        )
        rect = game_object.components.first

        rect.z_layer = 20

        expect(rect.z_layer).to eq(20)
      end
    end
  end

  describe ".rects" do
    it "registers rects in z_layer sorted order" do
      obj1 = Engine::GameObject.create(
        name: "High",
        components: [Engine::Components::UI::Rect.create(z_layer: 20)]
      )
      obj2 = Engine::GameObject.create(
        name: "Low",
        components: [Engine::Components::UI::Rect.create(z_layer: 5)]
      )
      obj3 = Engine::GameObject.create(
        name: "Mid",
        components: [Engine::Components::UI::Rect.create(z_layer: 10)]
      )

      rects = Engine::Components::UI::Rect.rects
      z_layers = rects.map(&:z_layer)

      expect(z_layers).to eq([5, 10, 20])
    end

    it "maintains insertion order for same z_layer" do
      obj1 = Engine::GameObject.create(
        name: "First",
        components: [Engine::Components::UI::Rect.create(z_layer: 10)]
      )
      obj2 = Engine::GameObject.create(
        name: "Second",
        components: [Engine::Components::UI::Rect.create(z_layer: 10)]
      )
      obj3 = Engine::GameObject.create(
        name: "Third",
        components: [Engine::Components::UI::Rect.create(z_layer: 10)]
      )

      rects = Engine::Components::UI::Rect.rects
      names = rects.map { |r| r.game_object.name }

      expect(names).to eq(["First", "Second", "Third"])
    end

    it "repositions rect when z_layer changes" do
      obj1 = Engine::GameObject.create(
        name: "A",
        components: [Engine::Components::UI::Rect.create(z_layer: 10)]
      )
      obj2 = Engine::GameObject.create(
        name: "B",
        components: [Engine::Components::UI::Rect.create(z_layer: 20)]
      )
      obj3 = Engine::GameObject.create(
        name: "C",
        components: [Engine::Components::UI::Rect.create(z_layer: 30)]
      )

      rect_b = obj2.components.first
      rect_b.z_layer = 5

      rects = Engine::Components::UI::Rect.rects
      names = rects.map { |r| r.game_object.name }

      expect(names).to eq(["B", "A", "C"])
    end

    it "removes rect on destroy" do
      obj = Engine::GameObject.create(
        name: "Test",
        components: [Engine::Components::UI::Rect.create(z_layer: 10)]
      )
      rect = obj.components.first

      expect(Engine::Components::UI::Rect.rects).to include(rect)

      rect.destroy

      expect(Engine::Components::UI::Rect.rects).not_to include(rect)
    end
  end

  describe "#ancestor_masks" do
    it "returns empty array when no parent has mask" do
      parent = Engine::GameObject.create(
        name: "Parent",
        components: [Engine::Components::UI::Rect.create]
      )

      child = Engine::GameObject.create(
        name: "Child",
        parent: parent,
        components: [Engine::Components::UI::Rect.create]
      )
      child_rect = child.components.first

      expect(child_rect.ancestor_masks).to eq([])
    end

    it "returns parent rect when parent has mask: true" do
      parent = Engine::GameObject.create(
        name: "Parent",
        components: [Engine::Components::UI::Rect.create(mask: true)]
      )
      parent_rect = parent.components.first

      child = Engine::GameObject.create(
        name: "Child",
        parent: parent,
        components: [Engine::Components::UI::Rect.create]
      )
      child_rect = child.components.first

      expect(child_rect.ancestor_masks).to eq([parent_rect])
    end

    it "returns multiple ancestor masks in order from outermost to innermost" do
      grandparent = Engine::GameObject.create(
        name: "Grandparent",
        components: [Engine::Components::UI::Rect.create(mask: true)]
      )
      grandparent_rect = grandparent.components.first

      parent = Engine::GameObject.create(
        name: "Parent",
        parent: grandparent,
        components: [Engine::Components::UI::Rect.create(mask: true)]
      )
      parent_rect = parent.components.first

      child = Engine::GameObject.create(
        name: "Child",
        parent: parent,
        components: [Engine::Components::UI::Rect.create]
      )
      child_rect = child.components.first

      expect(child_rect.ancestor_masks).to eq([grandparent_rect, parent_rect])
    end

    it "skips ancestors without mask: true" do
      grandparent = Engine::GameObject.create(
        name: "Grandparent",
        components: [Engine::Components::UI::Rect.create(mask: true)]
      )
      grandparent_rect = grandparent.components.first

      parent = Engine::GameObject.create(
        name: "Parent",
        parent: grandparent,
        components: [Engine::Components::UI::Rect.create(mask: false)]
      )

      child = Engine::GameObject.create(
        name: "Child",
        parent: parent,
        components: [Engine::Components::UI::Rect.create]
      )
      child_rect = child.components.first

      expect(child_rect.ancestor_masks).to eq([grandparent_rect])
    end
  end
end
