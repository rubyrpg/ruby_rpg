# frozen_string_literal: true

module ShrinkRacer
  class CarFollower < Engine::Component
    OFFSET = Vector[0, 0.4, -0.8]

    def initialize(target)
      @target = target
    end

    def start
      game_object.pos = target_pos
      game_object.rotation = target_rotation
    end

    def update(delta_time)
      game_object.pos = target_pos
      game_object.rotation = target_rotation
    end

    private

    def target_pos
      @target.local_to_world_coordinate(OFFSET / @target.scale[0])
    end

    def target_rotation
      @target.rotation *
        Engine::Quaternion.from_euler(Vector[0, 180, 0]) *
        Engine::Quaternion.from_angle_axis(10, game_object.right)
    end
  end
end
