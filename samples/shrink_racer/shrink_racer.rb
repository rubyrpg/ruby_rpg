require_relative "../../lib/ruby_rpg"
require "pry"

Engine.start do
  include ShrinkRacer

  Rendering::RenderPipeline.set_skybox_colors(
    ground: Vector[0.15, 0.1, 0.1],
    horizon: Vector[0.6, 0.3, 0.25],
    sky: Vector[0.08, 0.05, 0.2]
  )

  # Add post-processing effects
  Rendering::PostProcessingEffect.add(
    Rendering::PostProcessingEffect.ssr(max_steps: 128, max_ray_distance: 12.8, thickness: 0.5, ray_offset: 0.05)
  )
  Rendering::PostProcessingEffect.add(
    Rendering::PostProcessingEffect.bloom(threshold: 2.0, intensity: 0.2, blur_passes: 3, blur_scale: 3.0)
  )
  Rendering::PostProcessingEffect.add(
    Rendering::PostProcessingEffect.depth_of_field(focus_distance: 10, focus_range: 10)
  )


  # RoadTrack.create_gallery
  track = RoadTrack::TRACKS[:track_3]
  RoadTrack.create(track)

  car = Car.create_suv(track[:start_pos], track[:start_rot])

  Engine::GameObject.new(
    "Direction Light",
    rotation: Vector[-60, 180, 30],
    components: [
      Engine::Components::DirectionLight.new(
        colour: Vector[1.0, 0.6, 0.4],  # warm orange-pink twilight
        cast_shadows: true,
        shadow_distance: 20.0
      ),
    ])

  coin_counter = UIText.create(Vector[100, 1080 - 100, 0], Vector[0, 0, 0], 100, " ")
  Engine::GameObject.new(
    "Game Controller",
    components: [
      GameController.new(coin_counter.ui_renderers[0]),
    ],
  )

  CameraObject.create(car)
  #CameraObject.debug_camera
end
