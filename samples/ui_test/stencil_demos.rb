# frozen_string_literal: true

def create_stencil_demos
  box_size = 120

  # Flex container for all stencil demos
  flex_container = Engine::GameObject.create(
    name: "StencilDemos_Container",
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 210,
        top_offset: 60,
        right_ratio: 1.0, right_offset: -640,
        bottom_ratio: 1.0, bottom_offset: -190,
        z_layer: 200
      ),
      Engine::Components::UI::Flex.create(
        direction: :row,
        gap: 20,
        justify: :start
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_ui_material(0.15, 0.15, 0.15, 1.0)
      )
    ]
  )

  # Demo 1: Basic mask - smiley clipped by container
  mask_container = Engine::GameObject.create(
    name: "StencilDemo_BasicMask",
    parent: flex_container,
    components: [
      Engine::Components::UI::Rect.create(
        flex_width: box_size,
        flex_height: box_size,
        mask: true
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_ui_material(0.3, 0.1, 0.1, 1.0)
      )
    ]
  )
  Engine::GameObject.create(
    name: "StencilDemo_BasicMask_Smiley",
    parent: mask_container,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: -30, top_offset: -30,
        right_offset: -50, bottom_offset: -50
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_sprite_material("assets/smiley.png")
      )
    ]
  )

  # Demo 2: Sprite mask - color fill clipped to smiley shape
  smiley_mask = Engine::GameObject.create(
    name: "StencilDemo_SpriteMask",
    parent: flex_container,
    components: [
      Engine::Components::UI::Rect.create(
        flex_width: box_size,
        flex_height: box_size,
        mask: true
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_sprite_material("assets/smiley.png")
      )
    ]
  )
  Engine::GameObject.create(
    name: "StencilDemo_SpriteMask_Fill",
    parent: smiley_mask,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 0, top_offset: 0,
        right_offset: 0, bottom_offset: 0
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_ui_material(1.0, 0.0, 0.5, 1.0)
      )
    ]
  )

  # Demo 3: Nested masks - smiley clipped by both outer and inner mask
  outer_mask = Engine::GameObject.create(
    name: "StencilDemo_NestedOuter",
    parent: flex_container,
    components: [
      Engine::Components::UI::Rect.create(
        flex_width: box_size,
        flex_height: box_size,
        mask: true
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_ui_material(0.1, 0.1, 0.4, 1.0)
      )
    ]
  )
  inner_mask = Engine::GameObject.create(
    name: "StencilDemo_NestedInner",
    parent: outer_mask,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 15, top_offset: 15,
        right_offset: -15, bottom_offset: -15,
        mask: true
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_ui_material(0.1, 0.3, 0.1, 1.0)
      )
    ]
  )
  Engine::GameObject.create(
    name: "StencilDemo_NestedSmiley",
    parent: inner_mask,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: -20, top_offset: -20,
        right_offset: -40, bottom_offset: -40
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_sprite_material("assets/smiley.png")
      )
    ]
  )
end
