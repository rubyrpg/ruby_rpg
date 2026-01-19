# UI System

## Coordinate System

UI uses **Y-down** coordinates (0 at top, increases downward):

```
(0,0) ─────────────────▶ X
  │
  │    ┌─────────────┐
  │    │   UI Rect   │
  │    └─────────────┘
  ▼
  Y
```

## UI::Rect

Base layout component. Position via ratios (0.0-1.0) + pixel offsets:

```ruby
rect = UI::Rect.create(
  left_ratio: 0.0, right_ratio: 0.5,    # left half of parent
  top_ratio: 0.0, bottom_ratio: 0.9,    # top 10%
  left_offset: 10, top_offset: 5,       # pixel adjustments
  z_layer: 1                             # render order (higher = on top)
)
```

### z_layer
- Controls render order (lower renders first, higher renders on top)
- Children auto-inherit parent z_layer + 10 if not set

## UI::Flex

Flexbox-like layout. Requires a `UI::Rect` on the same GameObject.

```ruby
# Parent setup
parent = GameObject.create(
  components: [
    UI::Rect.create(...),
    UI::Flex.create(
      direction: :row,      # :row or :column
      gap: 10,              # pixels between children
      justify: :stretch     # see options below
    )
  ]
)
```

### Justify Options

```
:stretch (default)
┌──────────────────────────────┐
│ ┌────────┐ ┌────────┐ ┌────┐│
│ │ flex:2 │ │ flex:2 │ │ 1  ││  ← children fill space by weight
│ └────────┘ └────────┘ └────┘│
└──────────────────────────────┘

:start
┌──────────────────────────────┐
│┌──┐┌──┐┌──┐                  │
││  ││  ││  │                  │  ← packed at start
│└──┘└──┘└──┘                  │
└──────────────────────────────┘

:end
┌──────────────────────────────┐
│                  ┌──┐┌──┐┌──┐│
│                  │  ││  ││  ││  ← packed at end
│                  └──┘└──┘└──┘│
└──────────────────────────────┘

:center
┌──────────────────────────────┐
│         ┌──┐┌──┐┌──┐         │
│         │  ││  ││  │         │  ← centered
│         └──┘└──┘└──┘         │
└──────────────────────────────┘

:space_between
┌──────────────────────────────┐
│┌──┐        ┌──┐        ┌──┐ │
││  │        │  │        │  │ │  ← space between items
│└──┘        └──┘        └──┘ │
└──────────────────────────────┘

:space_around
┌──────────────────────────────┐
│  ┌──┐    ┌──┐    ┌──┐       │
│  │  │    │  │    │  │       │  ← equal space around each
│  └──┘    └──┘    └──┘       │
└──────────────────────────────┘

:space_evenly
┌──────────────────────────────┐
│   ┌──┐   ┌──┐   ┌──┐        │
│   │  │   │  │   │  │        │  ← equal gaps everywhere
│   └──┘   └──┘   └──┘        │
└──────────────────────────────┘
```

### Child Rect Properties for Flex

```ruby
# For :stretch justify - uses flex_weight
child = GameObject.create(
  parent: parent,
  components: [UI::Rect.create(flex_weight: 2)]  # takes 2x space vs weight:1 siblings
)

# For other justify modes - requires fixed size
child = GameObject.create(
  parent: parent,
  components: [UI::Rect.create(flex_width: 100, flex_height: 50)]
)
```

### flex_align

Cross-axis alignment for individual children (not yet fully documented).

## Example: Horizontal Button Bar

```ruby
# Container
bar = GameObject.create(
  name: "button_bar",
  components: [
    UI::Rect.create(
      left_ratio: 0.0, right_ratio: 0.0,
      top_ratio: 0.9, bottom_ratio: 0.0  # bottom 10% of screen
    ),
    UI::Flex.create(direction: :row, gap: 10, justify: :center)
  ]
)

# Buttons
3.times do |i|
  GameObject.create(
    name: "btn_#{i}",
    parent: bar,
    components: [
      UI::Rect.create(flex_width: 80, flex_height: 40),
      UI::SpriteRenderer.create(material: button_material)
    ]
  )
end
```

## Key Files

- `lib/engine/components/ui/rect.rb` - Base layout component
- `lib/engine/components/ui/flex.rb` - Flex container
- `lib/engine/components/ui/flex/stretch_layout.rb` - Stretch algorithm
- `lib/engine/components/ui/flex/pack_layout.rb` - Pack/justify algorithms
