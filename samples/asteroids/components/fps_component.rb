# frozen_string_literal: true

module Asteroids
  class FpsComponent < Engine::Component
    def start
      @fps_counter = game_object.ui_renderers.first
      @display = false
    end

    def update(delta_time)
      toggle_visibility if Engine::Input.key_down?(GLFW::KEY_D)
      @fps_counter.update_string( @display ? onscreen_message : '' )
    end

    def toggle_visibility
      @display = !@display
    end

    def onscreen_message
      [
        "FPS: #{Engine.fps.round(4)}",
        "Total Game Objects: #{Engine::GameObject.objects.count}",
        "",
        "Window: #{Engine::Window.height} x #{Engine::Window.width}",
        "FrameBuffer: #{Engine::Window.framebuffer_height} x #{Engine::Window.framebuffer_width}",
        "",
        "#{game_objects_tallied}"
      ].join("\n")
    end


    def game_objects_tallied
      Engine::GameObject.objects.map(&:name).tally.map do |game_obj, count|
        "#{game_obj} (#{count})"
      end.join("\n")
    end
  end
end
