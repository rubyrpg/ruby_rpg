require_relative "../../lib/ruby_rpg"
require_relative "components/spotlight_controller"
require_relative "components/sound_test"
require_relative "components/camera_rotator"
require_relative "components/spinner"
require_relative "components/debug_line_test"

def load_material(name)
  Engine::Serialization::YamlPersistence.load(File.join(GAME_DIR, "assets/#{name}.mat"))
end

Engine.start(debug_key: Engine::Input::KEY_BACKSPACE, fullscreen_key: Engine::Input::KEY_F) do
  include Cubes

  Rendering::RenderPipeline.set_skybox_colors(
    ground: Vector[0, 0, 0],
    horizon: Vector[0, 0, 0],
    sky: Vector[0, 0, 0]
  )

  # Post processing effects
  # Rendering::PostProcessingEffect.add_all([
  #   Rendering::PostProcessingEffect.ssao(kernel_size: 16, radius: 5.0, bias: 0.025, power: 4.0),
  #   Rendering::PostProcessingEffect.ssr(max_steps: 128, max_ray_distance: 256.0, thickness: 5.0),
  #   Rendering::PostProcessingEffect.tint(color: [1.0, 0.0, 0.0], intensity: 0.2),
  #   Rendering::PostProcessingEffect.bloom(threshold: 0.8, intensity: 1.0, blur_passes: 3, blur_scale: 5.0),
  #   Rendering::PostProcessingEffect.depth_of_field(focus_distance: 70.0, focus_range: 50.0, blur_amount: 2.0),
  # ])

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

  # sphere = Engine::StandardObjects::Sphere.create(
  #   pos: Vector[0, 20, 0],
  #   scale: Vector[10, 10, 10],
  #   material: load_material("hdr_sphere"),
  #   components: [
  #     Cubes::DebugLineTest.new
  #   ]
  # )
  # Engine::StandardObjects::Cube.create(
  #   pos: Vector[25, 20, -30],
  #   scale: Vector[16, 16, 16],
  #   components: [Spinner.create(speed: 45)]
  # )

  # Distortion cube demo
  distortion_mat = Engine::Material.create(
    shader: Engine::Shader.for('mesh_vertex.glsl', 'oit_distortion_frag.glsl', source: :engine),
    transparent: true
  )
  distortion_mat.set_vec3("baseColour", Vector[0.6, 0.8, 1.0])
  distortion_mat.set_float("distortionStrength", -0.08)
  distortion_mat.set_float("opacity", 0.25)
  distortion_mat.set_float("diffuseStrength", 0.1)
  distortion_mat.set_float("specularStrength", 3.0)
  distortion_mat.set_float("specularPower", 64.0)
  distortion_mat.set_float("roughness", 0.05)
  Engine::StandardObjects::Sphere.create(
    pos: Vector[0, 20, 5],
    scale: Vector[24, 24, 24],
    material: distortion_mat,
    components: [Spinner.create(speed: 30)]
  )

  # Engine::Serialization::YamlPersistence.load(File.join(GAME_DIR, "assets/floor.scene"))
  Engine::Serialization::YamlPersistence.load_all([File.join(GAME_DIR, "assets/wall_of_cubes.scene")])

  # # Transparent wall of cubes (OIT demo) - offset in Z from the opaque wall
  # transparent_colors = [
  #   Vector[1.0, 0.2, 0.2],  # red
  #   Vector[0.2, 1.0, 0.2],  # green
  #   Vector[0.2, 0.2, 1.0],  # blue
  #   Vector[1.0, 1.0, 0.2],  # yellow
  #   Vector[0.2, 1.0, 1.0],  # cyan
  # ]
  # 5.times do |col|
  #   4.times do |row|
  #     mat = Engine::Material.create(
  #       shader: Engine::Shader.default,
  #       transparent: true
  #     )
  #     mat.set_vec3("baseColour", transparent_colors[col])
  #     mat.set_float("diffuseStrength", 0.3)
  #     mat.set_float("specularStrength", 2.0)
  #     mat.set_float("specularPower", 32.0)
  #     mat.set_float("roughness", 0.1)
  #     mat.set_vec3("ambientLight", Vector[0.15, 0.15, 0.15])
  #     mat.set_float("opacity", 0.4)
  #
  #     Engine::StandardObjects::Cube.create(
  #       pos: Vector[-40 + col * 9, 5 + row * 9, -15],
  #       scale: Vector[8, 8, 8],
  #       material: mat,
  #       components: []
  #     )
  #   end
  # end

  Engine::GameObject.create(
    name: "DirectionalLight",
    pos: Vector[0, 50, 0],
    rotation: Vector[-70, 190, 0],
    components: [
      Engine::Components::DirectionLight.create(colour: Vector[2,2,2], cast_shadows: false, shadow_distance: 150.0)
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
