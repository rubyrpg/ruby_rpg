# Render Pipeline

## Overview

The engine uses a deferred-style render pipeline with MRT (Multiple Render Targets), shadow mapping, and post-processing.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           RENDER PIPELINE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. SHADOWS          2. MAIN 3D           3. SKYBOX                     │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐               │
│  │ Directional │     │ Color +     │     │ Render to   │               │
│  │ Spot        │────▶│ Normal/Rough│────▶│ Cubemap     │               │
│  │ Point (cube)│     │ (MRT)       │     │             │               │
│  └─────────────┘     └─────────────┘     └─────────────┘               │
│                             │                   │                       │
│                             ▼                   ▼                       │
│  4. POST-PROCESSING  ◀──────┴───────────────────┘                       │
│  ┌─────────────────────────────────────────────┐                       │
│  │ SSR → SSAO → Bloom → DOF → Tint → ...       │                       │
│  └─────────────────────────────────────────────┘                       │
│                             │                                           │
│                             ▼                                           │
│  5. UI                 6. BLIT TO SCREEN                               │
│  ┌─────────────┐     ┌─────────────┐                                   │
│  │ Sorted by   │────▶│ Final       │                                   │
│  │ z_layer     │     │ Output      │                                   │
│  └─────────────┘     └─────────────┘                                   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Stage Details

### 1. Shadow Maps

Renders depth from each light's perspective into texture arrays:

| Light Type | Storage | Max Shadows |
|------------|---------|-------------|
| Directional | 2D Texture Array | 4 |
| Spot | 2D Texture Array | 4 |
| Point | Cubemap Array (6 faces each) | 4 |

### 2. Main 3D Pass

- Renders to MRT (Multiple Render Targets):
  - `COLOR_ATTACHMENT0`: Color (RGB) + Alpha
  - `COLOR_ATTACHMENT1`: Normals (RGB) + Roughness (A)
- Depth buffer preserved for post-processing
- **Instanced rendering**: Objects grouped by material+mesh

### 3. Skybox

- Rendered to cubemap for reflections
- Gradient-based (ground/horizon/sky colors) or custom cubemap

### 4. Post-Processing

Effects applied in chain, ping-ponging between two render textures:

```ruby
# Add effects (order matters)
PostProcessingEffect.add(PostProcessingEffect.ssao)
PostProcessingEffect.add(PostProcessingEffect.bloom(threshold: 0.8))
PostProcessingEffect.add(PostProcessingEffect.tint(color: [1.0, 0.9, 0.8]))
```

#### Available Effects

| Effect | Description | Key Parameters |
|--------|-------------|----------------|
| `bloom` | Glow on bright areas | `threshold`, `intensity`, `blur_passes` |
| `ssao` | Ambient occlusion | `radius`, `kernel_size`, `power` |
| `ssr` | Screen-space reflections | `max_steps`, `max_ray_distance` |
| `depth_of_field` | Focus blur | `focus_distance`, `focus_range` |
| `tint` | Color grading | `color`, `intensity` |
| `depth_debug` | Visualize depth buffer | - |

### 5. UI Pass

- Depth testing disabled
- Rendered sorted by `z_layer` (lower first)
- See `agent_docs/ui_system.md`

### 6. Blit

Final texture copied to screen framebuffer.

## Instanced Rendering

Objects with same mesh+material are batched:

```
InstanceRenderer[mesh, material]
    └── MeshRenderer instances[] ─────▶ Single draw call
```

- Model matrices packed into VBO
- `GL.DrawElementsInstanced` for efficiency

## Lighting

### Light Types

```ruby
# Directional (sun-like) - direction comes from GameObject's rotation
DirectionLight.create(colour: [1, 1, 1], cast_shadows: true, shadow_distance: 50.0)

# Point (omni-directional)
PointLight.create(range: 50, colour: [1, 0.8, 0.6], cast_shadows: true)

# Spot - angles in degrees
SpotLight.create(range: 30, inner_angle: 12.5, outer_angle: 17.5, cast_shadows: true)
```

### Limits

| Light Type | Max Count | Max Shadow Casters |
|------------|-----------|-------------------|
| Point | 16 | 4 |
| Directional | 4 | 4 |
| Spot | 8 | 4 |

## GPU Profiling

Pipeline stages are timed via `GpuTimer`:

```
shadows: 0.5ms | main_3d: 2.1ms | skybox: 0.1ms | pp:Bloom: 0.8ms | ui: 0.2ms | blit: 0.1ms
```

## Key Files

- `lib/engine/rendering/render_pipeline.rb` - Main orchestration
- `lib/engine/rendering/instance_renderer.rb` - Batched drawing
- `lib/engine/rendering/shadow_map_array.rb` - 2D shadow storage
- `lib/engine/rendering/cubemap_shadow_map_array.rb` - Point light shadows
- `lib/engine/rendering/post_processing/` - All post-process effects
