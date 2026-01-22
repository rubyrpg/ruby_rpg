# frozen_string_literal: true

module Engine
  class Material
    include Serializable

    serialize :shader, :floats, :ints, :vec2s, :vec3s, :vec4s, :mat4s, :textures

    # Cache texture slot constants to avoid const_get every frame
    TEXTURE_SLOTS = Array.new(32) { |i| Object.const_get("Engine::GL::TEXTURE#{i}") }

    # Class-level texture binding cache
    @bound_textures = {}

    class << self
      attr_accessor :bound_textures
    end

    def self.bind_texture(slot, target, texture_id)
      Engine::GL.ActiveTexture(TEXTURE_SLOTS[slot])

      # Bind texture only if different for this slot
      unless @bound_textures[slot] == texture_id
        Engine::GL.BindTexture(target, texture_id)
        @bound_textures[slot] = texture_id
      end
    end

    attr_reader :shader

    def self.default_white_texture
      @default_white_texture ||= create_1x1_texture(255, 255, 255, 255)
    end

    def self.default_normal_texture
      @default_normal_texture ||= create_1x1_texture(128, 128, 255, 255)
    end

    def self.default_black_texture
      @default_black_texture ||= create_1x1_texture(0, 0, 0, 255)
    end

    def self.create_1x1_texture(r, g, b, a)
      tex = ' ' * 4
      Engine::GL.GenTextures(1, tex)
      texture_id = tex.unpack('L')[0]
      Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, texture_id)
      pixel = [r, g, b, a].pack('C*')
      Engine::GL.TexImage2D(Engine::GL::TEXTURE_2D, 0, Engine::GL::RGBA, 1, 1, 0, Engine::GL::RGBA, Engine::GL::UNSIGNED_BYTE, pixel)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MIN_FILTER, Engine::GL::NEAREST)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MAG_FILTER, Engine::GL::NEAREST)
      texture_id
    end

    def set_mat4(name, value)
      mat4s[name] = value
    end

    def set_vec2(name, value)
      vec2s[name] = value
    end

    def set_vec3(name, value)
      vec3s[name] = value
    end

    def set_vec4(name, value)
      vec4s[name] = value
    end

    def set_float(name, value)
      floats[name] = value
    end

    def set_int(name, value)
      ints[name] = value
    end

    def set_texture(name, texture)
      textures[name] = texture
    end

    # TODO: Runtime textures are not serializable. We need to revisit this
    # to make render targets serializable or find another approach.
    def set_runtime_texture(name, gl_id)
      runtime_textures[name] = gl_id
    end

    def set_cubemap(name, value)
      cubemaps[name] = value
    end

    def set_texture_array(name, value)
      texture_arrays[name] = value
    end

    def set_cubemap_array(name, value)
      cubemap_arrays[name] = value
    end

    def update_shader
      shader.use

      mat4s.each do |name, value|
        shader.set_mat4(name, value)
      end
      vec2s.each do |name, value|
        shader.set_vec2(name, value)
      end
      vec3s.each do |name, value|
        shader.set_vec3(name, value)
      end
      vec4s.each do |name, value|
        shader.set_vec4(name, value)
      end
      floats.each do |name, value|
        shader.set_float(name, value)
      end
      ints.each do |name, value|
        shader.set_int(name, value)
      end
      # Start with shader's expected textures (defaulting to nil for fallbacks)
      expected = shader.expected_textures.each_with_object({}) { |name, h| h[name] = nil }
      all_textures = expected.merge(textures).merge(runtime_textures)
      all_textures.each.with_index do |(name, value), slot|
        texture_id = if value.is_a?(Texture)
                       value.texture
                     elsif value
                       value
                     else
                       fallback_texture_for(name)
                     end
        Material.bind_texture(slot, Engine::GL::TEXTURE_2D, texture_id)
        shader.set_int(name, slot)
      end

      # Cubemaps start after regular textures
      cubemap_start_slot = all_textures.size
      cubemaps.each.with_index do |(name, value), i|
        slot = cubemap_start_slot + i
        texture_id = value || fallback_cubemap_for(name)
        Material.bind_texture(slot, Engine::GL::TEXTURE_CUBE_MAP, texture_id)
        shader.set_int(name, slot)
      end

      # Texture arrays start after cubemaps
      texture_array_start_slot = cubemap_start_slot + cubemaps.size
      texture_arrays.each.with_index do |(name, value), i|
        slot = texture_array_start_slot + i
        Material.bind_texture(slot, Engine::GL::TEXTURE_2D_ARRAY, value || 0)
        shader.set_int(name, slot)
      end

      # Cubemap arrays start after texture arrays
      cubemap_array_start_slot = texture_array_start_slot + texture_arrays.size
      cubemap_arrays.each.with_index do |(name, value), i|
        slot = cubemap_array_start_slot + i
        Material.bind_texture(slot, Engine::GL::TEXTURE_CUBE_MAP_ARRAY, value || 0)
        shader.set_int(name, slot)
      end
    end

    private

    def fallback_texture_for(name)
      case shader.texture_fallback(name)
      when :normal then self.class.default_normal_texture
      when :black then self.class.default_black_texture
      else self.class.default_white_texture
      end
    end

    def fallback_cubemap_for(name)
      case shader.cubemap_fallback(name)
      when :skybox
        Rendering::RenderPipeline.skybox_cubemap&.texture || 0
      else
        0
      end
    end

    def mat4s
      @mat4s ||= {}
    end

    def vec2s
      @vec2s ||= {}
    end

    def vec3s
      @vec3s ||= {}
    end

    def vec4s
      @vec4s ||= {}
    end

    def floats
      @floats ||= {}
    end

    def ints
      @ints ||= {}
    end

    def textures
      @textures ||= {}
    end

    def runtime_textures
      @runtime_textures ||= {}
    end

    def cubemaps
      @cubemaps ||= {}
    end

    def texture_arrays
      @texture_arrays ||= {}
    end

    def cubemap_arrays
      @cubemap_arrays ||= {}
    end
  end
end
