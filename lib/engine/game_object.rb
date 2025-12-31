require "matrix"

module Engine
  class GameObject
    def self.method_added(name)
      @methods ||= Set.new
      return if name == :initialize || name == :destroyed?
      @methods.add(name)
    end

    attr_accessor :name, :components, :renderers, :ui_renderers, :created_at
    attr_reader :pos, :scale, :parent, :local_version

    def initialize(name = "Game Object", pos: Vector[0, 0, 0], rotation: 0, scale: Vector[1, 1, 1], components: [], parent: nil)
      GameObject.object_spawned(self)
      @local_version = 0
      @cached_world_version = nil
      @pos = Vector[pos[0], pos[1], pos[2] || 0]
      if rotation.is_a?(Numeric)
        @rotation_quaternion = Quaternion.from_euler(Vector[0, 0, rotation])
      elsif rotation.is_a?(Quaternion)
        @rotation_quaternion = rotation
      else
        @rotation_quaternion = Quaternion.from_euler(rotation)
      end
      @scale = scale
      @name = name
      @components = components.select { |component| !component.renderer? && !component.ui_renderer? }
      @renderers = components.select { |component| component.renderer? }
      @ui_renderers = components.select { |component| component.ui_renderer? }
      @created_at = Time.now
      @parent = parent
      parent.add_child(self) if parent

      components.each { |component| component.set_game_object(self) }
      components.each(&:start)
    end

    def to_s
      @name
    end

    def children
      @children ||= Set.new
    end

    def add_child(child)
      child.parent = self
      children << child
    end

    def parent=(parent)
      @parent.children.delete(self) if @parent
      @parent = parent
      @local_version += 1
      parent.children << self if parent
    end

    def pos=(value)
      @pos = value
      @local_version += 1
    end

    def scale=(value)
      @scale = value
      @local_version += 1
    end

    def rotation
      @rotation_quaternion
    end

    def rotation=(value)
      raise "Rotation must be a Quaternion" unless value.is_a?(Quaternion)

      @rotation_quaternion = value
      @local_version += 1
    end

    def euler_angles
      rotation.to_euler
    end

    def x
      @pos[0]
    end

    def x=(value)
      @pos = Vector[value, y, z]
      @local_version += 1
    end

    def y
      @pos[1]
    end

    def y=(value)
      @pos = Vector[x, value, z]
      @local_version += 1
    end

    def z
      @pos[2]
    end

    def z=(value)
      @pos = Vector[x, y, value]
      @local_version += 1
    end

    def local_to_world_coordinate(local)
      local_x4 = Matrix[[local[0], local[1], local[2], 1.0]]
      world = local_x4 * model_matrix
      Vector[world[0, 0], world[0, 1], world[0, 2]]
    end

    def world_to_local_coordinate(world)
      world_x4 = Matrix[[world[0], world[1], world[2], 1.0]]
      local = world_x4 * model_matrix.inverse
      Vector[local[0, 0], local[0, 1], local[0, 2]]
    end

    def local_to_world_direction(local)
      local_to_world_coordinate(local) - local_to_world_coordinate(Vector[0, 0, 0])
    end

    def rotate_around(axis, angle)
      rotation_quaternion = Quaternion.from_angle_axis(angle, axis)

      self.rotation = rotation_quaternion * rotation
    end

    def world_transform_version
      @local_version + (@parent&.world_transform_version || 0)
    end

    def model_matrix
      current_version = world_transform_version
      return @cached_world_matrix if @cached_world_version == current_version

      @cached_world_version = current_version
      @cached_world_matrix = compute_world_matrix
    end

    private def compute_local_matrix
      rot = euler_angles * Math::PI / 180

      cos_x = Math.cos(rot[0])
      cos_y = Math.cos(rot[1])
      cos_z = Math.cos(rot[2])

      sin_x = Math.sin(rot[0])
      sin_y = Math.sin(rot[1])
      sin_z = Math.sin(rot[2])

      Matrix[
        [scale[0] * (cos_y * cos_z), scale[0] * (-cos_y * sin_z), scale[0] * sin_y, 0],
        [scale[1] * (cos_x * sin_z + sin_x * sin_y * cos_z), scale[1] * (cos_x * cos_z - sin_x * sin_y * sin_z), scale[1] * -sin_x * cos_y, 0],
        [scale[2] * (sin_x * sin_z - cos_x * sin_y * cos_z), scale[2] * (sin_x * cos_z + cos_x * sin_y * sin_z), scale[2] * cos_x * cos_y, 0],
        [x, y, z, 1]
      ]
    end

    private def compute_world_matrix
      local = compute_local_matrix
      if parent
        local * parent.model_matrix
      else
        local
      end
    end

    def destroyed?
      @destroyed
    end

    def destroy!
      return unless GameObject.objects.include?(self)
      children.each(&:destroy!)
      components.each(&:destroy!)
      ui_renderers.each(&:destroy!)
      renderers.each(&:destroy!)

      GameObject.destroyed_objects << self unless @destroyed
      @destroyed = true
    end

    def _erase!
      GameObject.objects.delete(self)
      parent.children.delete(self) if parent
      name = @name
      self.class.instance_variable_get(:@methods).each do |method|
        singleton_class.send(:undef_method, method)
        singleton_class.send(:define_method, method) { raise "This object has been destroyed: #{name}" }
      end
    end

    def self.erase_destroyed_objects
      destroyed_objects.each do |object|
        object._erase!
      end
      @destroyed_objects = []
    end

    def up
      return @up if @cached_up_rotation == rotation
      @cached_up_rotation = rotation.dup
      @up = local_to_world_direction(Vector[0, 1, 0])
    end

    def right
      return @right if @cached_right_rotation == rotation
      @cached_right_rotation = rotation.dup
      @right = local_to_world_direction(Vector[1, 0, 0])
    end

    def forward
      return @forward if @cached_forward_rotation == rotation
      @cached_forward_rotation = rotation.dup
      @forward = local_to_world_direction(Vector[0, 0, 1])
    end

    def self.destroy_all
      GameObject.objects.dup.each do |object|
        object.destroy! unless object.destroyed?
      end
    end

    def self.update_all(delta_time)
      GameObject.objects.each do |object|
        object.components.each { |component| component.update(delta_time) }
      end

      Component.erase_destroyed_components
      GameObject.erase_destroyed_objects
    end

    def self.mesh_renderers
      GameObject.objects.flat_map do |object|
        object.renderers
      end
    end

    def self.ui_renderers
      GameObject.objects.flat_map do |object|
        object.ui_renderers
      end
    end

    def self.object_spawned(object)
      objects << object
    end

    def self.objects
      @objects ||= []
    end

    def self.destroyed_objects
      @destroyed_objects ||= []
    end
  end
end
