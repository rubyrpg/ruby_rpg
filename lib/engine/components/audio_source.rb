# frozen_string_literal: true

module Engine::Components
  class AudioSource < Engine::Component
    serialize :clip_path, :radius

    def awake
      @radius ||= 1000
      @clip = NativeAudio::Clip.new(@clip_path)
      @source = NativeAudio::AudioSource.new(@clip)
    end

    def play
      @source.play
    end

    def stop
      @source.stop
    end

    def pause
      @source.pause
    end

    def resume
      @source.resume
    end

    def volume=(volume)
      @source.set_volume(volume)
    end

    def update(delta_time)
      camera = Engine::Camera.instance
      local_pos = camera.game_object.world_to_local_coordinate(game_object.pos)
      angle = Math.atan2(local_pos[0], -local_pos[2]) * 180 / Math::PI
      angle = (angle + 360) % 360
      distance = (local_pos.magnitude * 255 / @radius).clamp(0, 255)
      
      @source.set_pos(angle, distance)
    end
  end
end
