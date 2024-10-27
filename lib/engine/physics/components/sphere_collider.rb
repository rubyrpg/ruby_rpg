# frozen_string_literal: true

module Engine::Physics::Components
  class SphereCollider < Engine::Component
    attr_accessor :radius

    def initialize(radius)
      @radius = radius
    end

    def collision_for(other_collider)
      distance = (game_object.pos - other_collider.game_object.pos).magnitude
      min_distance = radius + other_collider.radius

      return nil if distance >= min_distance

      direction = (other_collider.game_object.pos - game_object.pos).normalize
      collision_point = collision_point(direction, min_distance - distance)
      magnitude = normal_impulse_magnitude(direction, other_collider, collision_point)

      return nil if magnitude <= 0

      normal_impulse = -direction * magnitude
      tangential_impulse = tangential_impulse(other_collider, normal_impulse, collision_point)

      puts "normal_impulse: #{normal_impulse}"
      puts "tangential_impulse: #{tangential_impulse}"
      puts "total impulse: #{normal_impulse + tangential_impulse}"

      Engine::Physics::Collision.new(normal_impulse + tangential_impulse, collision_point)
    end

    def static?
      rigidbody.nil?
    end

    def inverse_mass
      1.0 / rigidbody.mass
    end

    def velocity(pos)
      rigidbody&.velocity_at_point(pos) || Vector[0, 0, 0]
    end

    def rigidbody
      game_object.components.find { |c| c.is_a?(Rigidbody) }
    end

    private

    def combined_coefficient_of_restitution(other_collider)
      return rigidbody.coefficient_of_restitution if other_collider.static?

      rigidbody.coefficient_of_restitution * other_collider.rigidbody.coefficient_of_restitution
    end

    def combined_coefficient_of_friction(other_collider)
      return rigidbody.coefficient_of_friction if other_collider.static?

      rigidbody.coefficient_of_friction * other_collider.rigidbody.coefficient_of_friction
    end

    def collision_point(direction, overlap)
      game_object.pos + direction * (radius - overlap / 2)
    end

    def normal_impulse_magnitude(direction, other_collider, collision_point)
      (
        if other_collider.static?
          v_r = velocity(collision_point)
          (v_r.dot(direction) * 2) / inverse_mass
        else
          v_r = velocity(collision_point) - other_collider.velocity(collision_point)
          (v_r.dot(direction) * 2) / (inverse_mass + other_collider.inverse_mass)
        end) * combined_coefficient_of_restitution(other_collider)
    end

    def tangential_impulse(other_collider, normal_impulse, collision_point)
      normal_direction = normal_impulse.normalize
      v_t = if other_collider.static?
              velocity(collision_point)
            else
              velocity(collision_point) - other_collider.velocity(collision_point)
            end

      v_t_without_normal = -((v_t - v_t.dot(normal_direction) * normal_direction))
      return Vector[0, 0, 0] if v_t_without_normal.magnitude == 0

      relevant_speed = [v_t_without_normal.magnitude, normal_impulse.magnitude * combined_coefficient_of_friction(other_collider)].min
      v_t_without_normal.normalize * relevant_speed / 2
    end
  end
end
