# frozen_string_literal: true

module Engine::Physics
  module PhysicsResolver
    def self.resolve
      rigidbodies.each do |rb|
        apply_collisions(rb)
      end
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

    def self.rigidbodies
      Engine::GameObject.objects.map do |go|
        go.components.find { |c| c.is_a?(Engine::Physics::Components::Rigidbody) }
      end.compact
    end

    def self.colliders
      Engine::GameObject.objects.map do |go|
        go.components.select { |c| c.is_a?(Components::SphereCollider) }
      end.flatten
    end
  end
end
