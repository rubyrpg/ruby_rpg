require_relative "../../lib/ruby_rpg"
require_relative "components/spotlight_controller"
require_relative "components/sound_test"
require_relative "components/camera_rotator"
require_relative "components/spinner"
require_relative "components/debug_line_test"

def load_material(name)
  Engine::Serialization::YamlPersistence.load(File.join(GAME_DIR, "assets/#{name}.mat"))
end

Engine.start do
  include Cubes

  # Post processing effects
  Rendering::PostProcessingEffect.add_all([
    Rendering::PostProcessingEffect.ssao(kernel_size: 16, radius: 5.0, bias: 0.025, power: 4.0),
    Rendering::PostProcessingEffect.ssr(max_steps: 128, max_ray_distance: 256.0, thickness: 5.0),
    # Rendering::PostProcessingEffect.tint(color: [1.0, 0.0, 0.0], intensity: 0.2),
    Rendering::PostProcessingEffect.bloom(threshold: 0.8, intensity: 1.0, blur_passes: 3, blur_scale: 5.0),
    # Rendering::PostProcessingEffect.depth_of_field(focus_distance: 70.0, focus_range: 50.0, blur_amount: 2.0),
  ])

  # Camera rig - parent handles movement, child has the camera component
  # This tests that camera matrix updates when parent moves
  camera_rig = Engine::GameObject.create(
    name: "CameraRig",
    pos: Vector[0, 50, 0],
    rotation: Vector[20, 0, 0],
    components: [
      Cubes::CameraRotator.new
    ])

  Engine::GameObject.create(
    name: "Camera",
    parent: camera_rig,
    components: [
      Engine::Components::PerspectiveCamera.create(fov: 45.0, aspect: 1920.0 / 1080.0, near: 0.1, far: 1000.0)
    ])

  sphere = Engine::StandardObjects::Sphere.create(
    pos: Vector[0, 20, 0],
    scale: Vector[10, 10, 10],
    material: load_material("hdr_sphere"),
    components: [
      Engine::Components::AudioSource.create(clip_path: File.join(GAME_DIR, "assets/knock.wav")),
      Cubes::SoundTest.new,
      Cubes::DebugLineTest.new
    ]
  )
  Engine::StandardObjects::Cube.create(
    pos: Vector[25, 20, -30],
    scale: Vector[16, 16, 16],
    components: [Spinner.create(speed: 45)]
  )

  Engine::Serialization::YamlPersistence.load(File.join(GAME_DIR, "assets/floor.scene"))
  Engine::Serialization::YamlPersistence.load_all([File.join(GAME_DIR, "assets/wall_of_cubes.scene")])

  Engine::GameObject.create(
    name: "DirectionalLight",
    pos: Vector[0, 50, 0],
    rotation: Vector[-70, 190, 0],
    components: [
      Engine::Components::DirectionLight.create(colour: Vector[1,1,1], cast_shadows: true, shadow_distance: 150.0)
    ]
  )

  # UI Example - a panel in the bottom-left corner with a nested child
  ui_material = Engine::Material.create(shader: Engine::Shader.ui_sprite)
  ui_material.set_vec4("spriteColor", [0.2, 0.2, 0.8, 0.8])  # semi-transparent blue
  ui_material.set_runtime_texture("image", Engine::Material.default_white_texture)

  child_material = Engine::Material.create(shader: Engine::Shader.ui_sprite)
  child_material.set_vec4("spriteColor", [0.8, 0.2, 0.2, 1.0])  # red
  child_material.set_runtime_texture("image", Engine::Material.default_white_texture)

  panel = Engine::GameObject.create(
    name: "UIPanel",
    components: [
      Engine::Components::UI::Rect.create(
        left_ratio: 0.02, right_ratio: 0.75,
        bottom_ratio: 0.02, top_ratio: 0.7
      ),
      Engine::Components::UI::SpriteRenderer.create(material: ui_material)
    ]
  )


  Engine::GameObject.create(
    name: "UIButton",
    parent: panel,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10, right_offset: 10,
        bottom_offset: 10, top_offset: 10
      ),
      Engine::Components::UI::SpriteRenderer.create(material: child_material)
    ]
  )
end
