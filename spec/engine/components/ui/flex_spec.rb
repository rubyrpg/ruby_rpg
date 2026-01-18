# frozen_string_literal: true

describe Engine::Components::UI::Flex do
  before do
    allow(Engine::Window).to receive(:framebuffer_width).and_return(800)
    allow(Engine::Window).to receive(:framebuffer_height).and_return(600)
  end

  describe ".create" do
    it "creates a Flex with default values" do
      flex = Engine::Components::UI::Flex.create
      flex.awake

      expect(flex.direction).to eq(:row)
      expect(flex.gap).to eq(0)
      expect(flex.justify).to eq(:stretch)
    end

    it "creates a Flex with custom values" do
      flex = Engine::Components::UI::Flex.create(direction: :column, gap: 10, justify: :start)
      flex.awake

      expect(flex.direction).to eq(:column)
      expect(flex.gap).to eq(10)
      expect(flex.justify).to eq(:start)
    end
  end

  describe "#rect_for_child" do
    context "with row direction" do
      it "divides width equally among children" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UI::Rect.create,
            Engine::Components::UI::Flex.create(direction: :row, gap: 0)
          ]
        )

        child1 = Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UI::Rect.create]
        )

        child2 = Engine::GameObject.create(
          name: "Child2",
          parent: parent,
          components: [Engine::Components::UI::Rect.create]
        )

        child1_rect = child1.components.first
        child2_rect = child2.components.first

        rect1 = child1_rect.computed_rect
        rect2 = child2_rect.computed_rect

        # Each child should get half the width (400px)
        expect(rect1.left).to eq(0)
        expect(rect1.right).to eq(400)
        expect(rect1.width).to eq(400)

        expect(rect2.left).to eq(400)
        expect(rect2.right).to eq(800)
        expect(rect2.width).to eq(400)

        # Full height (Y-down: top=0, bottom=600)
        expect(rect1.top).to eq(0)
        expect(rect1.bottom).to eq(600)
        expect(rect2.top).to eq(0)
        expect(rect2.bottom).to eq(600)
      end

      it "applies gap between children" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UI::Rect.create,
            Engine::Components::UI::Flex.create(direction: :row, gap: 20)
          ]
        )

        child1 = Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UI::Rect.create]
        )

        child2 = Engine::GameObject.create(
          name: "Child2",
          parent: parent,
          components: [Engine::Components::UI::Rect.create]
        )

        rect1 = child1.components.first.computed_rect
        rect2 = child2.components.first.computed_rect

        # 800px - 20px gap = 780px / 2 = 390px each
        expect(rect1.left).to eq(0)
        expect(rect1.right).to eq(390)

        expect(rect2.left).to eq(410)  # 390 + 20 gap
        expect(rect2.right).to eq(800)
      end
    end

    context "with column direction" do
      it "divides height equally among children, top to bottom" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UI::Rect.create,
            Engine::Components::UI::Flex.create(direction: :column, gap: 0)
          ]
        )

        child1 = Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UI::Rect.create]
        )

        child2 = Engine::GameObject.create(
          name: "Child2",
          parent: parent,
          components: [Engine::Components::UI::Rect.create]
        )

        rect1 = child1.components.first.computed_rect
        rect2 = child2.components.first.computed_rect

        # Y-down: first child at top (top=0)
        expect(rect1.top).to eq(0)
        expect(rect1.bottom).to eq(300)
        expect(rect1.height).to eq(300)

        # Second child below (top=300)
        expect(rect2.top).to eq(300)
        expect(rect2.bottom).to eq(600)
        expect(rect2.height).to eq(300)

        # Full width
        expect(rect1.left).to eq(0)
        expect(rect1.right).to eq(800)
      end

      it "applies gap between children" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UI::Rect.create,
            Engine::Components::UI::Flex.create(direction: :column, gap: 20)
          ]
        )

        child1 = Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UI::Rect.create]
        )

        child2 = Engine::GameObject.create(
          name: "Child2",
          parent: parent,
          components: [Engine::Components::UI::Rect.create]
        )

        rect1 = child1.components.first.computed_rect
        rect2 = child2.components.first.computed_rect

        # Y-down: 600px - 20px gap = 580px / 2 = 290px each
        expect(rect1.top).to eq(0)
        expect(rect1.bottom).to eq(290)

        expect(rect2.top).to eq(310)  # 290 + 20 gap
        expect(rect2.bottom).to eq(600)
      end
    end

    context "with three children" do
      it "divides space into thirds" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UI::Rect.create,
            Engine::Components::UI::Flex.create(direction: :row, gap: 0)
          ]
        )

        3.times do |i|
          Engine::GameObject.create(
            name: "Child#{i}",
            parent: parent,
            components: [Engine::Components::UI::Rect.create]
          )
        end

        children = parent.children.to_a
        rects = children.map { |c| c.components.first.computed_rect }

        # Each should be ~266.67px wide
        expect(rects[0].left).to be_within(0.01).of(0)
        expect(rects[0].right).to be_within(0.01).of(800.0 / 3)

        expect(rects[1].left).to be_within(0.01).of(800.0 / 3)
        expect(rects[1].right).to be_within(0.01).of(800.0 * 2 / 3)

        expect(rects[2].left).to be_within(0.01).of(800.0 * 2 / 3)
        expect(rects[2].right).to be_within(0.01).of(800)
      end
    end

    context "with justify: :start" do
      it "positions children at start with their flex_width" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UI::Rect.create,
            Engine::Components::UI::Flex.create(direction: :row, justify: :start, gap: 10)
          ]
        )

        Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UI::Rect.create(flex_width: 100)]
        )

        Engine::GameObject.create(
          name: "Child2",
          parent: parent,
          components: [Engine::Components::UI::Rect.create(flex_width: 150)]
        )

        children = parent.children.to_a
        rect1 = children[0].components.first.computed_rect
        rect2 = children[1].components.first.computed_rect

        # First child at left edge, 100px wide
        expect(rect1.left).to eq(0)
        expect(rect1.right).to eq(100)
        expect(rect1.width).to eq(100)

        # Second child after gap, 150px wide
        expect(rect2.left).to eq(110)  # 100 + 10 gap
        expect(rect2.right).to eq(260)
        expect(rect2.width).to eq(150)

        # Both full height (Y-down)
        expect(rect1.top).to eq(0)
        expect(rect1.bottom).to eq(600)
      end

      it "raises error when flex_width is missing" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UI::Rect.create,
            Engine::Components::UI::Flex.create(direction: :row, justify: :start)
          ]
        )

        Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UI::Rect.create]  # no flex_width!
        )

        child_rect = parent.children.first.components.first
        expect { child_rect.computed_rect }
          .to raise_error("UI::Rect requires flex_width when parent Flex has justify: :start")
      end
    end

    context "with justify: :end" do
      it "positions children at end" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UI::Rect.create,
            Engine::Components::UI::Flex.create(direction: :row, justify: :end, gap: 10)
          ]
        )

        Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UI::Rect.create(flex_width: 100)]
        )

        Engine::GameObject.create(
          name: "Child2",
          parent: parent,
          components: [Engine::Components::UI::Rect.create(flex_width: 150)]
        )

        children = parent.children.to_a
        rect1 = children[0].components.first.computed_rect
        rect2 = children[1].components.first.computed_rect

        # Children at right edge: 800 - 100 - 10 - 150 = 540 remaining
        expect(rect1.left).to eq(540)
        expect(rect1.right).to eq(640)

        expect(rect2.left).to eq(650)
        expect(rect2.right).to eq(800)
      end
    end

    context "with justify: :center" do
      it "positions children in center" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UI::Rect.create,
            Engine::Components::UI::Flex.create(direction: :row, justify: :center, gap: 0)
          ]
        )

        Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UI::Rect.create(flex_width: 200)]
        )

        children = parent.children.to_a
        rect1 = children[0].components.first.computed_rect

        # 800 - 200 = 600 remaining, 300 on each side
        expect(rect1.left).to eq(300)
        expect(rect1.right).to eq(500)
      end
    end

    context "with column direction and justify: :start" do
      it "positions children from top with their flex_height" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UI::Rect.create,
            Engine::Components::UI::Flex.create(direction: :column, justify: :start, gap: 10)
          ]
        )

        Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UI::Rect.create(flex_height: 50)]
        )

        Engine::GameObject.create(
          name: "Child2",
          parent: parent,
          components: [Engine::Components::UI::Rect.create(flex_height: 80)]
        )

        children = parent.children.to_a
        rect1 = children[0].components.first.computed_rect
        rect2 = children[1].components.first.computed_rect

        # Y-down: first child at top, 50px tall
        expect(rect1.top).to eq(0)
        expect(rect1.bottom).to eq(50)
        expect(rect1.height).to eq(50)

        # Second child below gap, 80px tall
        expect(rect2.top).to eq(60)  # 50 + 10 gap
        expect(rect2.bottom).to eq(140)
        expect(rect2.height).to eq(80)

        # Both full width
        expect(rect1.left).to eq(0)
        expect(rect1.right).to eq(800)
      end
    end

    context "with cross-axis sizing" do
      context "row direction with flex_height" do
        it "uses flex_height for child height and aligns at top" do
          parent = Engine::GameObject.create(
            name: "Parent",
            components: [
              Engine::Components::UI::Rect.create,
              Engine::Components::UI::Flex.create(direction: :row, gap: 0)
            ]
          )

          Engine::GameObject.create(
            name: "Child1",
            parent: parent,
            components: [Engine::Components::UI::Rect.create(flex_height: 100)]
          )

          Engine::GameObject.create(
            name: "Child2",
            parent: parent,
            components: [Engine::Components::UI::Rect.create]  # no flex_height, should stretch
          )

          children = parent.children.to_a
          rect1 = children[0].components.first.computed_rect
          rect2 = children[1].components.first.computed_rect

          # Child1 should be 100px tall, aligned at top
          expect(rect1.top).to eq(0)
          expect(rect1.bottom).to eq(100)
          expect(rect1.height).to eq(100)

          # Child2 should stretch to full height
          expect(rect2.top).to eq(0)
          expect(rect2.bottom).to eq(600)
          expect(rect2.height).to eq(600)
        end
      end

      context "column direction with flex_width" do
        it "uses flex_width for child width and aligns at left" do
          parent = Engine::GameObject.create(
            name: "Parent",
            components: [
              Engine::Components::UI::Rect.create,
              Engine::Components::UI::Flex.create(direction: :column, gap: 0)
            ]
          )

          Engine::GameObject.create(
            name: "Child1",
            parent: parent,
            components: [Engine::Components::UI::Rect.create(flex_width: 200)]
          )

          Engine::GameObject.create(
            name: "Child2",
            parent: parent,
            components: [Engine::Components::UI::Rect.create]  # no flex_width, should stretch
          )

          children = parent.children.to_a
          rect1 = children[0].components.first.computed_rect
          rect2 = children[1].components.first.computed_rect

          # Child1 should be 200px wide, aligned at left
          expect(rect1.left).to eq(0)
          expect(rect1.right).to eq(200)
          expect(rect1.width).to eq(200)

          # Child2 should stretch to full width
          expect(rect2.left).to eq(0)
          expect(rect2.right).to eq(800)
          expect(rect2.width).to eq(800)
        end
      end
    end

    context "with flex_weight in stretch mode" do
      it "distributes space by weight" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UI::Rect.create,
            Engine::Components::UI::Flex.create(direction: :row, justify: :stretch, gap: 0)
          ]
        )

        Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UI::Rect.create(flex_weight: 1)]
        )

        Engine::GameObject.create(
          name: "Child2",
          parent: parent,
          components: [Engine::Components::UI::Rect.create(flex_weight: 2)]
        )

        Engine::GameObject.create(
          name: "Child3",
          parent: parent,
          components: [Engine::Components::UI::Rect.create(flex_weight: 1)]
        )

        children = parent.children.to_a
        rect1 = children[0].components.first.computed_rect
        rect2 = children[1].components.first.computed_rect
        rect3 = children[2].components.first.computed_rect

        # Total weight = 4, so: 1/4 = 200px, 2/4 = 400px, 1/4 = 200px
        expect(rect1.width).to eq(200)
        expect(rect2.width).to eq(400)
        expect(rect3.width).to eq(200)

        expect(rect1.left).to eq(0)
        expect(rect1.right).to eq(200)
        expect(rect2.left).to eq(200)
        expect(rect2.right).to eq(600)
        expect(rect3.left).to eq(600)
        expect(rect3.right).to eq(800)
      end

      it "combines fixed width with weighted children" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UI::Rect.create,
            Engine::Components::UI::Flex.create(direction: :row, justify: :stretch, gap: 0)
          ]
        )

        # Fixed 100px
        Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UI::Rect.create(flex_width: 100)]
        )

        # Weight 2 of remaining 700px
        Engine::GameObject.create(
          name: "Child2",
          parent: parent,
          components: [Engine::Components::UI::Rect.create(flex_weight: 2)]
        )

        # Weight 1 of remaining 700px
        Engine::GameObject.create(
          name: "Child3",
          parent: parent,
          components: [Engine::Components::UI::Rect.create(flex_weight: 1)]
        )

        children = parent.children.to_a
        rect1 = children[0].components.first.computed_rect
        rect2 = children[1].components.first.computed_rect
        rect3 = children[2].components.first.computed_rect

        # Child1 = 100px fixed
        # Remaining = 700px, total weight = 3
        # Child2 = 700 * 2/3 = 466.67px
        # Child3 = 700 * 1/3 = 233.33px
        expect(rect1.width).to eq(100)
        expect(rect2.width).to be_within(0.01).of(700 * 2.0 / 3)
        expect(rect3.width).to be_within(0.01).of(700 * 1.0 / 3)

        expect(rect1.left).to eq(0)
        expect(rect1.right).to eq(100)
      end
    end
  end
end
