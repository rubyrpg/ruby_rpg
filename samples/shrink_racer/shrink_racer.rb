require_relative "../../lib/ruby_rpg"
require "pry"

Engine.start do
  include ShrinkRacer

  # Add post-processing effects
  Rendering::PostProcessingEffect.add(
    Rendering::PostProcessingEffect.ssr(max_steps: 128, step_size: 1, thickness: 2.0)
  )
  Rendering::PostProcessingEffect.add(
    Rendering::PostProcessingEffect.bloom(threshold: 2.0, intensity: 0.2, blur_passes: 3, blur_scale: 3.0)
  )
  Rendering::PostProcessingEffect.add(
    Rendering::PostProcessingEffect.depth_of_field(focus_distance: 0.95, focus_range: 0.3, blur_amount: 3.0)
  )


  Engine::GameObject.new(
    "Direction Light",
    rotation: Vector[-60, 180, 30],
    components: [
      Engine::Components::DirectionLight.new(
        colour: Vector[1.0, 0.6, 0.4],  # warm orange-pink twilight
      ),
    ])

  # RoadTrack.create_gallery
  track = RoadTrack::TRACKS[:track_3]
  RoadTrack.create(track)


  coin_counter = UIText.create(Vector[100, 1080 - 100, 0], Vector[0, 0, 0], 100, " ")
  Engine::GameObject.new(
    "Game Controller",
    components: [
      GameController.new(coin_counter.ui_renderers[0]),
    ],
  )

  car = Car.create_suv(track[:start_pos], track[:start_rot])
  CameraObject.create(car)
  #CameraObject.debug_camera
end
