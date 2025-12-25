# frozen_string_literal: true

module Engine
  class Material
    attr_reader :shader
    attr_accessor :roughness, :metallic

    def initialize(shader)
      @shader = shader
      @roughness = 1.0  # default: fully rough (no reflections)
      @metallic = 0.0   # default: non-metallic
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

    def set_texture(name, value)
      textures[name] = value
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
      textures.each.with_index do |(name, value), slot|
        GL.ActiveTexture(Object.const_get("GL::TEXTURE#{slot}"))
        if value
          GL.BindTexture(GL::TEXTURE_2D, value)
        else
          GL.BindTexture(GL::TEXTURE_2D, 0)
        end
        shader.set_int(name, slot)
      end

      # Cubemaps start after regular textures
      cubemap_start_slot = textures.size
      cubemaps.each.with_index do |(name, value), i|
        slot = cubemap_start_slot + i
        GL.ActiveTexture(Object.const_get("GL::TEXTURE#{slot}"))
        if value
          GL.BindTexture(GL::TEXTURE_CUBE_MAP, value)
        else
          GL.BindTexture(GL::TEXTURE_CUBE_MAP, 0)
        end
        shader.set_int(name, slot)
      end

      # Texture arrays start after cubemaps
      texture_array_start_slot = cubemap_start_slot + cubemaps.size
      texture_arrays.each.with_index do |(name, value), i|
        slot = texture_array_start_slot + i
        GL.ActiveTexture(Object.const_get("GL::TEXTURE#{slot}"))
        if value
          GL.BindTexture(GL::TEXTURE_2D_ARRAY, value)
        else
          GL.BindTexture(GL::TEXTURE_2D_ARRAY, 0)
        end
        shader.set_int(name, slot)
      end

      # Cubemap arrays start after texture arrays
      cubemap_array_start_slot = texture_array_start_slot + texture_arrays.size
      cubemap_arrays.each.with_index do |(name, value), i|
        slot = cubemap_array_start_slot + i
        GL.ActiveTexture(Object.const_get("GL::TEXTURE#{slot}"))
        if value
          GL.BindTexture(GL::TEXTURE_CUBE_MAP_ARRAY, value)
        else
          GL.BindTexture(GL::TEXTURE_CUBE_MAP_ARRAY, 0)
        end
        shader.set_int(name, slot)
      end
    end

    private

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
