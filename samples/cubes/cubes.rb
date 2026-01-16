require_relative "../../lib/ruby_rpg"
require_relative "components/spotlight_controller"
require_relative "components/sound_test"
require_relative "components/camera_rotator"
require_relative "components/spinner"

def load_material(name)
  Engine::Serialization::YamlPersistence.load(File.join(GAME_DIR, "assets/#{name}.mat"))
end

Engine.start do
  include Cubes

  # Navy night sky
  Rendering::RenderPipeline.set_skybox_colors(
    ground: Vector[0.02, 0.02, 0.05],
    horizon: Vector[0.05, 0.05, 0.4],
    sky: Vector[0.02, 0.03, 0.3]
  )

  # Post processing effects
  Rendering::PostProcessingEffect.add_all([
    Rendering::PostProcessingEffect.ssao(kernel_size: 16, radius: 5.0, bias: 0.025, power: 4.0),
    Rendering::PostProcessingEffect.ssr(max_steps: 128, max_ray_distance: 256.0, thickness: 5.0),
    # Rendering::PostProcessingEffect.tint(color: [1.0, 0.0, 0.0], intensity: 0.2),
    Rendering::PostProcessingEffect.bloom(threshold: 0.8, intensity: 1.0, blur_passes: 3, blur_scale: 5.0),
    # Rendering::PostProcessingEffect.depth_of_field(focus_distance: 70.0, focus_range: 50.0, blur_amount: 2.0),
  ])

  Engine::GameObject.create(
    name: "Camera",
    pos: Vector[0, 50, 0],
    rotation: Vector[20, 0, 0],
    components: [
      Cubes::CameraRotator.new,
      Engine::Components::PerspectiveCamera.create(fov: 45.0, aspect: 1920.0 / 1080.0, near: 0.1, far: 1000.0)
    ])

  sphere = Engine::StandardObjects::Sphere.create(
    pos: Vector[0, 20, 0],
    scale: Vector[10, 10, 10],
    material: load_material("hdr_sphere"),
    components: [
      Engine::Components::AudioSource.create(clip_path: File.join(GAME_DIR, "assets/boom.wav")),
      Cubes::SoundTest.new
    ]
  )
  Engine::StandardObjects::Cube.create(
    pos: Vector[25, 20, -30],
    scale: Vector[16, 16, 16],
    components: [Spinner.create(speed: 45)]
  )

  # Wall of colourful cubes (loaded from scene file)
  Engine::Serialization::YamlPersistence.load_all([File.join(GAME_DIR, "assets/wall_of_cubes.scene")])

  # # Single white directional light for testing SSR
  Engine::GameObject.create(
    name: "DirectionalLight",
    pos: Vector[0, 50, 0],
    rotation: Vector[-70, 190, 0],
    components: [
      Engine::Components::DirectionLight.create(colour: Vector[1,1,1], cast_shadows: true, shadow_distance: 150.0)
    ]
  )

  # Point light (dimmed)
  # Engine::GameObject.new(
  #   "PointLight",
  #   pos: Vector[-20, 70, -10],
  #   components: [
  #     Engine::Components::PointLight.create(range: 150, colour: Vector[0.1, 0.1, 0.1], cast_shadows: true),
  #     SpotlightController.new
  #   ]
  # )
  #
  # # Spot light
  # Engine::GameObject.new(
  #   "SpotLight",
  #   pos: Vector[-30, 40, 20],
  #   rotation: Vector[-180, -20, 0],
  #   components: [
  #     Engine::Components::DirectionLight.create(colour: Vector[1, 1, 1], cast_shadows: true)
  #   ]
  # )

  # Sphere.create(spotlight_pos, 0, 2)  # temporarily disabled for shadow debug

  # Floor (loaded from scene file)
  Engine::Serialization::YamlPersistence.load(File.join(GAME_DIR, "assets/floor.scene"))


  # Back wall (disabled for testing)
  # Plane.create(Vector[0, 25, -50], Vector[0, 0, 0], 50, chessboard, brick_normal)

  # World-space text (follows camera perspective)
  Text.create(Vector[0, 35, 0], Vector[0, 0, 0], 5, "Hello World")

  # UI text (screen-space, fixed position)
  UIText.create(Vector[50, 50, 0], Vector[0, 0, 0], 30, "UI Text")

  # UI Sprite (screen-space quad - top-left corner)
  ui_sprite_material = Engine::Material.create(shader: Engine::Shader.ui_sprite)
  ui_sprite_material.set_texture("image", Engine::Texture.for("assets/chessboard.png"))
  ui_sprite_material.set_vec4("spriteColor", [1, 1, 1, 1])
  Engine::GameObject.create(
    name: "UI Sprite",
    pos: Vector[0, 0, 0],
    components: [
      Engine::Components::UISpriteRenderer.create(
        v1: Vector[100, 900],    # top-left
        v2: Vector[300, 900],    # top-right
        v3: Vector[300, 700],    # bottom-right
        v4: Vector[100, 700],    # bottom-left
        material: ui_sprite_material
      )
    ]
  )
end
