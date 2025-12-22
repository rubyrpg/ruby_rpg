require_relative "../../lib/ruby_rpg"
require "pry"

Engine.start do
  include ShrinkRacer

  # Add post-processing effects
  Rendering::PostProcessingEffect.add(
    Rendering::PostProcessingEffect.bloom(threshold: 0.6, intensity: 0.3, blur_passes: 3, blur_scale: 3.0)
  )
  #Rendering::PostProcessingEffect.add(
  #  Rendering::PostProcessingEffect.tint(color: [1.0, 0.8, 0.6], intensity: 0.5)
  #)

  Engine::GameObject.new(
    "Direction Light",
    rotation: Vector[-60, 180, 30],
    components: [
      Engine::Components::DirectionLight.new(
        colour: Vector[1, 1, 1],
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
