# frozen_string_literal: true

module Engine::Physics::Components
  class Rigidbody < Engine::Component
    attr_accessor :velocity,
                  :angular_velocity,
                  :force,
                  :impulses,
                  :mass,
                  :coefficient_of_restitution,
                  :coefficient_of_friction

    def initialize(
      velocity: Vector[0, 0, 0],
      angular_velocity: Vector[0, 0, 0],
      mass: 1,
      inertia_tensor: nil,
      gravity: Vector[0, -9.81, 0],
      coefficient_of_restitution: 1,
      coefficient_of_friction: 0
    )
      @velocity = velocity
      @angular_velocity = angular_velocity
      @force = gravity * mass
      @gravity = gravity
      @impulses = []
      @angular_impulses = []
      @mass = mass
      @inertia_tensor = inertia_tensor || Matrix[
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1]
      ] * mass
      @coefficient_of_restitution = coefficient_of_restitution
      @coefficient_of_friction = coefficient_of_friction
    end

    def update(delta_time)
      @velocity += acceleration * delta_time
      @velocity += @impulses.reduce(Vector[0, 0, 0]) { |acc, impulse| acc + impulse } / @mass
      @impulses = []
      @game_object.pos += @velocity * delta_time

      total_angular_impulse = @angular_impulses.reduce(Vector[0, 0, 0]) { |acc, impulse| acc + impulse }
      if total_angular_impulse.magnitude > 0
        angular_inertia =
          if moment_of_inertia == 0
            impulse_direction = total_angular_impulse.normalize
            impulse_direction.dot(@inertia_tensor * impulse_direction)
          else
            moment_of_inertia
          end
        @angular_velocity += total_angular_impulse / angular_inertia
      end
      @angular_impulses = []
      @game_object.rotate_around(angular_velocity, delta_time * angular_velocity.magnitude) if angular_velocity.magnitude > 0
    end

    def apply_impulse(impulse, point)
      @impulses << impulse
      @angular_impulses << (game_object.pos - point).cross(impulse)
    end

    def apply_angular_impulse(impulse)
      @angular_impulses << impulse
    end

    def colliders
      @game_object.components.select { |c| c.is_a?(SphereCollider) }
    end

    def kinetic_energy
      0.5 * @mass * @velocity.magnitude ** 2 +
        0.5 * moment_of_inertia * @angular_velocity.magnitude ** 2
    end

    def momentum
      @mass * @velocity
    end

    def angular_momentum(origin = Vector[0, 0, 0])
      moment_of_inertia * @angular_velocity +
        (game_object.pos - origin).cross(momentum)
    end

    def velocity_at_point(point)
      velocity + (angular_velocity.cross(game_object.pos - point) * Math::PI / 180)
    end

    private

    def acceleration
      @force / @mass
    end

    def moment_of_inertia
      return 0 if @angular_velocity.magnitude == 0

      angular_velocity_direction = @angular_velocity.normalize
      angular_velocity_direction.dot(@inertia_tensor * angular_velocity_direction)
    end
  end
end
