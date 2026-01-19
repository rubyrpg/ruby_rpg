# Adding Components

## Component Template

**CRITICAL: Never use `initialize`** - all components use the factory pattern:

```ruby
class MyComponent < Component
  include Serializable
  serialize :speed, :health  # declare serializable attributes

  def awake
    # initialization logic (called after create)
    @internal_state = []
  end

  def start
    # called once before first update
  end

  def update(delta_time)
    # called every frame
  end

  def destroy!
    # cleanup before removal
    super
  end
end
```

## Usage

```ruby
obj = GameObject.create(
  name: "player",
  pos: Vector[0, 0, 0],
  components: [MyComponent.create(speed: 10, health: 100)]
)
```

## Component Lifecycle

```
.create() → awake() → start() → update(dt)* → destroy!() → _erase!()
```

## Renderer Components

Override these methods to control render pass:

```ruby
class MyRenderer < Component
  def renderer?
    true  # rendered in 3D pass
  end
end

class MyUIRenderer < Component
  def ui_renderer?
    true  # rendered in UI pass (screen space)
  end
end
```

## Adding Shaders

1. Create `.glsl` files in `lib/engine/shaders/`
2. Access via `Shader.from_file(vertex_path, fragment_path)` or use presets like `Shader.default`, `Shader.ui_sprite`
3. Texture fallbacks are declared in shader source via `// @fallback` comments

## Adding UI Elements

UI uses Y-down coordinate system (0 at top):

```ruby
GameObject.create(
  components: [
    UI::Rect.create(
      left_ratio: 0.0, right_ratio: 0.5,   # left half of parent
      top_ratio: 0.0, bottom_ratio: 0.1,   # top 10%
      z_layer: 1                            # render order
    )
  ]
)
```

## Real Examples

- Simple component: `samples/asteroids/components/ship/ship_engine.rb`
- Renderer: `lib/engine/components/renderers/mesh_renderer.rb`
- UI component: `lib/engine/components/ui/rect.rb`
