# frozen_string_literal: true

module Engine::Physics
  module PhysicsResolver
    def self.resolve
      rigidbodies.each do |rb|
        apply_collisions(rb)
      end
    end

    def self.rigidbodies
      @cached_rigidbodies ||= []
    end

    def self.colliders
      @cached_colliders ||= []
    end

    def self.register_rigidbody(rigidbody)
      rigidbodies << rigidbody
    end

    def self.unregister_rigidbody(rigidbody)
      rigidbodies.delete(rigidbody)
    end

    def self.register_collider(collider)
      colliders << collider
    end

    def self.unregister_collider(collider)
      colliders.delete(collider)
    end

    private

    def self.apply_collisions(rigidbody)
      other_colliders = colliders.reject { |c| rigidbody.colliders.include?(c) }

      rigidbody.colliders.map do |collider|
        other_colliders.map do |other_collider|
          collider.collision_for(other_collider)
        end.compact
      end.flatten.each do |collision|
        rigidbody.apply_impulse(collision.impulse, collision.point)
      end
    end
  end
end
