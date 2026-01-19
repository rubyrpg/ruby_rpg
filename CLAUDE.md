# Ruby RPG - Game Engine

A Ruby OpenGL 2D/3D game engine for building games with a component-based architecture (similar to Unity).

## Quick Commands

```
bundle exec rspec spec/path/to_spec.rb   # Run specific test (preferred - system tests slow)
bundle exec rspec                         # Full test suite
bundle exec import samples/<name>/assets   # Regenerate assets after adding OBJ/fonts
bundle exec ruby samples/asteroids/asteroids.rb  # Run a sample
```

## Project Structure

```
lib/engine/          # Core engine code
├── components/      # Components + renderers
├── physics/         # Rigidbody, colliders
├── rendering/       # RenderPipeline, post-processing
├── shaders/         # GLSL shaders
└── serialization/   # Scene save/load

samples/             # Example games (asteroids, cubes, shrink_racer, ui_test)
spec/                # RSpec tests
```

## CRITICAL: Component Factory Pattern

**NEVER use `initialize`** in serializable classes. Serialization bypasses `initialize`, so use `.create()` + `awake()` instead:

```ruby
class MyComponent < Component
  include Serializable
  serialize :speed

  def awake
    @internal = []  # init here, not initialize
  end

  def update(delta_time)
    # game logic
  end
end

# Usage:
Engine::GameObject.create(
  pos: Vector[0, 0, 0],
  components: [MyComponent.create(speed: 10)]
)
```

See `agent_docs/adding_components.md` for full patterns.

## DO NOT MODIFY

- `**/_imported/**` - Generated files. Regenerate with `bundle exec import`

## Debugging

- `Backspace` - Trigger pry debugger
- `Escape` - Close window
- `F` - Toggle fullscreen

## Detailed Guides

For in-depth documentation, read these when relevant:

- `agent_docs/architecture.md` - System design, game loop, class relationships
- `agent_docs/render_pipeline.md` - Rendering stages, shadows, post-processing, lighting
- `agent_docs/adding_components.md` - Component patterns, renderers, shaders
- `agent_docs/ui_system.md` - UI::Rect, UI::Flex layouts, z_layer sorting
- `agent_docs/testing.md` - TestDriver, screenshot tests, custom matchers
- `agent_docs/serialization.md` - Scene save/load, YAML persistence
