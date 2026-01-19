# Serialization System

## Overview

The engine supports YAML-based scene serialization for saving/loading game state.

## Making Classes Serializable

```ruby
class MyComponent < Component
  include Serializable
  serialize :speed, :health, :target  # declare what to save

  def awake
    @internal_cache = []  # non-serialized state
  end
end
```

Only attributes listed in `serialize` are persisted. Instance variables not listed are ignored.

## Saving & Loading Scenes

```ruby
# Save an object (e.g., a GameObject)
YamlPersistence.save(game_object, "my_scene.yaml")

# Save multiple objects
YamlPersistence.save_all([obj1, obj2], "my_scene.yaml")

# Load a scene (returns the deserialized object)
obj = YamlPersistence.load("my_scene.yaml")
```

## How It Works

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
│  GameObject     │────▶│  GraphSerializer │────▶│  YAML File  │
│  + Components   │     │  (handles refs)  │     │             │
└─────────────────┘     └──────────────────┘     └─────────────┘
```

- **ObjectSerializer**: Converts individual objects to/from hashes
- **GraphSerializer**: Handles object graphs with cross-references (via UUIDs)
- **YamlPersistence**: File I/O layer

## Object References

Objects are tracked by UUID. When serializing references between objects (e.g., a component pointing to another GameObject), the system stores UUIDs and resolves them on load.

## Key Files

- `lib/engine/serialization/serializable.rb` - The `Serializable` mixin
- `lib/engine/serialization/graph_serializer.rb` - Reference handling
- `lib/engine/serialization/yaml_persistence.rb` - File save/load
