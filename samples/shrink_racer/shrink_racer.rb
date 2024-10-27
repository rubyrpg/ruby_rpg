require_relative "../../lib/engine/engine"
require "pry"

ROOT = File.expand_path(File.join(__dir__))
ASSETS_DIR = File.expand_path(File.join(__dir__, "assets"))

Engine.start(base_dir: File.dirname(__FILE__)) do
  include ShrinkRacer

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
