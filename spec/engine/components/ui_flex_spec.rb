# frozen_string_literal: true

describe Engine::Components::UIFlex do
  before do
    allow(Engine::Window).to receive(:framebuffer_width).and_return(800)
    allow(Engine::Window).to receive(:framebuffer_height).and_return(600)
  end

  describe ".create" do
    it "creates a UIFlex with default values" do
      flex = Engine::Components::UIFlex.create
      flex.awake

      expect(flex.direction).to eq(:row)
      expect(flex.gap).to eq(0)
    end

    it "creates a UIFlex with custom values" do
      flex = Engine::Components::UIFlex.create(direction: :column, gap: 10)
      flex.awake

      expect(flex.direction).to eq(:column)
      expect(flex.gap).to eq(10)
    end
  end

  describe "#rect_for_child" do
    context "with row direction" do
      it "divides width equally among children" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UIRect.create,
            Engine::Components::UIFlex.create(direction: :row, gap: 0)
          ]
        )

        child1 = Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UIRect.create]
        )

        child2 = Engine::GameObject.create(
          name: "Child2",
          parent: parent,
          components: [Engine::Components::UIRect.create]
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

        # Full height
        expect(rect1.bottom).to eq(0)
        expect(rect1.top).to eq(600)
        expect(rect2.bottom).to eq(0)
        expect(rect2.top).to eq(600)
      end

      it "applies gap between children" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UIRect.create,
            Engine::Components::UIFlex.create(direction: :row, gap: 20)
          ]
        )

        child1 = Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UIRect.create]
        )

        child2 = Engine::GameObject.create(
          name: "Child2",
          parent: parent,
          components: [Engine::Components::UIRect.create]
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
            Engine::Components::UIRect.create,
            Engine::Components::UIFlex.create(direction: :column, gap: 0)
          ]
        )

        child1 = Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UIRect.create]
        )

        child2 = Engine::GameObject.create(
          name: "Child2",
          parent: parent,
          components: [Engine::Components::UIRect.create]
        )

        rect1 = child1.components.first.computed_rect
        rect2 = child2.components.first.computed_rect

        # First child at top
        expect(rect1.top).to eq(600)
        expect(rect1.bottom).to eq(300)
        expect(rect1.height).to eq(300)

        # Second child below
        expect(rect2.top).to eq(300)
        expect(rect2.bottom).to eq(0)
        expect(rect2.height).to eq(300)

        # Full width
        expect(rect1.left).to eq(0)
        expect(rect1.right).to eq(800)
      end

      it "applies gap between children" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UIRect.create,
            Engine::Components::UIFlex.create(direction: :column, gap: 20)
          ]
        )

        child1 = Engine::GameObject.create(
          name: "Child1",
          parent: parent,
          components: [Engine::Components::UIRect.create]
        )

        child2 = Engine::GameObject.create(
          name: "Child2",
          parent: parent,
          components: [Engine::Components::UIRect.create]
        )

        rect1 = child1.components.first.computed_rect
        rect2 = child2.components.first.computed_rect

        # 600px - 20px gap = 580px / 2 = 290px each
        expect(rect1.top).to eq(600)
        expect(rect1.bottom).to eq(310)

        expect(rect2.top).to eq(290)  # 310 - 20 gap
        expect(rect2.bottom).to eq(0)
      end
    end

    context "with three children" do
      it "divides space into thirds" do
        parent = Engine::GameObject.create(
          name: "Parent",
          components: [
            Engine::Components::UIRect.create,
            Engine::Components::UIFlex.create(direction: :row, gap: 0)
          ]
        )

        3.times do |i|
          Engine::GameObject.create(
            name: "Child#{i}",
            parent: parent,
            components: [Engine::Components::UIRect.create]
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
  end
end
