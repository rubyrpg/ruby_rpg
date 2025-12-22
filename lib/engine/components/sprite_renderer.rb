# frozen_string_literal: true

module Engine::Components
  class SpriteRenderer < Engine::Component
    attr_reader :material, :frame_coords, :frame_rate, :loop

    def initialize(material, frame_coords: nil, frame_rate: 1, loop: true)
      @material = material
      @frame_coords = frame_coords || [{ tl: Vector[0, 0], width: 1, height: 1 }]
      @frame_rate = frame_rate
      @loop = loop
    end

    def colour=(value)
      material.set_vec4("spriteColor", colour_to_vec4(value))
    end

    def colour_to_vec4(value)
      if value.is_a?(Array)
        value
      else
        [value[:r], value[:g], value[:b], value[:a] || 1.0]
      end
    end

    def renderer?
      true
    end

    def start
      @start_time = Time.now
      @mesh_renderer = MeshRenderer.new(Engine::Mesh.quad, material)
      @mesh_renderer.set_game_object(game_object)
      @mesh_renderer.start
      update_frame_coords
    end

    def update(delta_time)
      update_frame_coords
      @mesh_renderer.update(delta_time)
    end

    def destroy
      @mesh_renderer.destroy
    end

    private

    def update_frame_coords
      current_frame_index = ((Time.now - @start_time) * @frame_rate).to_i
      current_frame_index = if @loop
                              current_frame_index % @frame_coords.length
                            else
                              [@frame_coords.length - 1, current_frame_index].min
                            end

      frame = @frame_coords[current_frame_index]
      material.set_vec4("frameCoords", [
        frame[:tl][0],
        frame[:tl][1],
        frame[:width],
        frame[:height]
      ])
    end
  end
end
