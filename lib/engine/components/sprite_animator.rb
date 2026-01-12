# frozen_string_literal: true

module Engine::Components
  class SpriteAnimator < Engine::Component
    serialize :material, :frame_coords, :frame_rate, :loop

    attr_reader :frame_rate, :loop

    def awake
      @frame_rate ||= 1
      @loop = true if @loop.nil?
    end

    def start
      @start_time = Time.now
      update_frame
    end

    def update(delta_time)
      update_frame
    end

    private

    def update_frame
      current_frame_index = ((Time.now - @start_time) * @frame_rate).to_i
      current_frame_index = if @loop
                              current_frame_index % @frame_coords.length
                            else
                              [@frame_coords.length - 1, current_frame_index].min
                            end

      frame = @frame_coords[current_frame_index]
      @material.set_vec4("frameCoords", [
        frame[:tl][0],
        frame[:tl][1],
        frame[:width],
        frame[:height]
      ])
    end
  end
end
