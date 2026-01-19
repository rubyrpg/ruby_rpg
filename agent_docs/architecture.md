# Architecture Overview

## Game Loop

```
┌─────────────────────────────────────────────────────────────────┐
│                         Engine.start()                          │
├─────────────────────────────────────────────────────────────────┤
│  Game Loop: physics → update components → render → swap buffers │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐     │
│   │  GameObject  │───▶│  Component   │    │   Renderer   │     │
│   │  (transform) │    │  (logic)     │    │  (drawing)   │     │
│   └──────────────┘    └──────────────┘    └──────────────┘     │
│          │                                                      │
│          ▼                                                      │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐     │
│   │   Physics    │    │   Material   │───▶│   Shader     │     │
│   │  (colliders) │    │  (uniforms)  │    │   (GLSL)     │     │
│   └──────────────┘    └──────────────┘    └──────────────┘     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
lib/engine/
├── components/           # Game components (logic + renderers)
│   ├── renderers/       # MeshRenderer, SpriteRenderer, FontRenderer
│   └── ui/              # UI-specific (Rect, Flex, SpriteRenderer)
├── physics/             # Rigidbody, colliders, PhysicsResolver
├── rendering/           # RenderPipeline, shadow maps, post-processing
├── shaders/             # GLSL vertex/fragment shaders
├── metal/               # macOS Metal compute shaders
├── opengl/              # Windows/Linux OpenGL compute shaders
├── serialization/       # YAML scene save/load system
└── importers/           # Asset import (OBJ, fonts)

samples/                 # Example games
├── asteroids/           # 2D arcade shooter
├── cubes/               # 3D rendering demo
├── shrink_racer/        # 3D racing game
└── ui_test/             # UI system showcase
```

## Key Classes

### GameObject (`lib/engine/game_object.rb`)
- Central entity with hierarchical transform
- Holds components, renderers, UI renderers
- Transform: `pos`, `rotation` (Quaternion), `scale`

### Component (`lib/engine/component.rb`)
- Base class for all game logic
- Lifecycle: `awake()` → `start()` → `update(dt)` → `destroy!()`

### RenderPipeline (`lib/engine/rendering/render_pipeline.rb`)
- Coordinates all rendering
- Order: Shadows → 3D → Skybox → Post-processing → UI → Blit

### Material (`lib/engine/material.rb`)
- Shader state: uniforms, textures
- Texture slot caching for performance

## Transform Hierarchy

```
Parent GameObject (world pos)
    └── Child GameObject (local pos relative to parent)
         └── Grandchild (local pos relative to child)
```

Access:
- `game_object.pos` - local position
- `game_object.local_to_world_coordinate(Vector[0,0,0])` - computed world position
- `game_object.local_to_world_coordinate(vec)` - transform local to world
- `game_object.world_to_local_coordinate(vec)` - transform world to local

## Platform Specifics

| Platform | OpenGL | Compute Shaders |
|----------|--------|-----------------|
| macOS | 4.1 | Metal (`lib/engine/metal/`) |
| Windows/Linux | 4.3 | OpenGL (`lib/engine/opengl/`) |

Detection: `OS.mac?`, `OS.windows?`

## Rendering Order

1. Shadow maps (direction, point, spot lights)
2. Main 3D pass (sorted by material+mesh for instancing)
3. Skybox
4. Post-processing (bloom, SSR, SSAO, DOF, tint)
5. UI pass (sorted by z_layer)
6. Blit to screen
