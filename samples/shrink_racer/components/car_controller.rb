# frozen_string_literal: true

module ShrinkRacer
  class CarController < Engine::Component
    ACCELERATION = 100.0
    DRAG = 3.0
    SIDE_DRAG = 10.0
    WIND_UP_TIME = 0.25

    def initialize(spinner)
      @spinner = spinner
      @speed = Vector[0, 0, 0]
      @current_time = 0.0
      @last_shrink_time = -999.0
      @last_collision_time = -999.0
      @acceleration = 0
      @scale_count = 0
      @car_debugger = UIText.create(Vector[100, 1080 - 200, 0], Vector[0, 0, 0], 50, "").ui_renderers.first
      @visible_debugger = false
    end

    def start
      @target_scale = game_object.scale
    end

    def update(delta_time)
      @current_time += delta_time
      game_object.scale += 15.0 * (@target_scale - game_object.scale) * delta_time
      update_debugger

      if @current_time - @last_collision_time > 0.5
        if Engine::Input.key?(Engine::Input::KEY_W)
          @acceleration += delta_time * max_acceleration / WIND_UP_TIME
        elsif Engine::Input.key?(Engine::Input::KEY_S)
          @acceleration -= delta_time * max_acceleration / WIND_UP_TIME
        else
          @acceleration = 0
        end
      else
        @acceleration = 0
      end

      @acceleration = @acceleration.clamp(-max_acceleration / 2, max_acceleration)

      thrust = @acceleration
      drag = -@speed.dot(game_object.forward.normalize) * DRAG
      side_drag = -@speed.dot(game_object.right.normalize) * SIDE_DRAG
      @speed += game_object.forward.normalize * (thrust + drag) * delta_time
      @speed += game_object.right.normalize * side_drag * delta_time

      game_object.pos += @speed * delta_time

      torque = 0
      if Engine::Input.key?(Engine::Input::KEY_A)
        torque = -60
      end
      if Engine::Input.key?(Engine::Input::KEY_D)
        torque += 60
      end

      game_object.rotation *= Engine::Quaternion.from_euler(Vector[0, torque, 0] * delta_time)

    end

    def update_debugger
      onscreen_text = [
        "Car Scale: #{game_object.scale}",
        "Target Scale: #{@target_scale}",
        "Scale Count: #{@scale_count}",
        "Acceleration: #{@acceleration.round(3)}",
        "Max Acceleration: #{max_acceleration.round(3)}"
      ].join("\n")

      toggle_debugger_visibility if Engine::Input.key?(Engine::Input::KEY_SLASH)
      @car_debugger.update_string( @visible_debugger ? onscreen_text : '' )
    end

    def toggle_debugger_visibility
      @visible_debugger = !@visible_debugger
    end

    def max_acceleration
      ACCELERATION * game_object.scale[0]
    end

    def collect_coin
      if @scale_count <= 3
        @target_scale /= 0.8
        @scale_count += 1
      end
    end

    def collide(tree_pos)
      flat_pos = Vector[game_object.pos[0], 0, game_object.pos[2]]
      flat_tree_pos = Vector[tree_pos[0], 0, tree_pos[2]]

      incident = (flat_tree_pos - flat_pos).normalize
      collision_speed = @speed.dot(incident)
      if collision_speed > 0
        @speed -= collision_speed * incident * 1.8
        @acceleration = 0
        @last_collision_time = @current_time

        if @current_time - @last_shrink_time > 0.5
          if @scale_count >= -3
            @target_scale *= 0.8
            @scale_count -= 1
          end
          @spinner.spin
          @last_shrink_time = @current_time
        end
      end
    end
  end
end
