# frozen_string_literal: true

module Asteroids
  class Gun < Engine::Component
    COOLDOWN = 0.3

    def update(delta_time)
      fire if Engine::Input.key?(Engine::Input::KEY_SPACE)
    end

    def fire
      return if @last_fire && Time.now - @last_fire < COOLDOWN
      @last_fire = Time.now

      direction = game_object.local_to_world_direction(Vector[0, 1, 0]).normalize
      spawn_pos = game_object.pos + direction * 30
      Bullet.create(spawn_pos, game_object.rotation)
    end
  end
end
