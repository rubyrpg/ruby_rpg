# frozen_string_literal: true

module Rendering
  class SSAOEffect
    include Effect

    def initialize(kernel_size: 16, radius: 0.5, bias: 0.025, power: 2.0, blur_size: 2, depth_threshold: 1000.0)
      @kernel_size = [kernel_size, 64].min
      @radius = radius
      @bias = bias
      @power = power
      @blur_size = blur_size
      @depth_threshold = depth_threshold
    end

    def apply(input_rt, output_rt, screen_quad)
      ensure_textures(input_rt.width, input_rt.height)

      camera = Engine::Camera.instance
      GL.Disable(GL::DEPTH_TEST)

      # Pass 1: Generate SSAO
      @ssao_rt.bind
      GL.ClearColor(1.0, 1.0, 1.0, 1.0)
      GL.Clear(GL::COLOR_BUFFER_BIT)

      ssao_material.set_runtime_texture("depthTexture", PostProcessingEffect.depth_texture)
      ssao_material.set_runtime_texture("normalTexture", PostProcessingEffect.normal_texture)
      ssao_material.set_runtime_texture("noiseTexture", noise_texture)

      ssao_material.set_mat4("projection", camera.projection.transpose)
      ssao_material.set_mat4("view", camera.view_matrix)
      ssao_material.set_mat4("inverseVP", camera.inverse_vp_matrix)
      ssao_material.set_float("nearPlane", camera.near)
      ssao_material.set_float("farPlane", camera.far)

      noise_scale = [@ssao_rt.width / 4.0, @ssao_rt.height / 4.0]
      ssao_material.set_vec2("noiseScale", noise_scale)

      screen_quad.draw_with_material(ssao_material)
      @ssao_rt.unbind

      # Pass 2: Blur SSAO
      @blur_rt.bind
      GL.Clear(GL::COLOR_BUFFER_BIT)

      blur_material.set_runtime_texture("ssaoTexture", @ssao_rt.color_texture)
      blur_material.set_runtime_texture("depthTexture", PostProcessingEffect.depth_texture)

      screen_quad.draw_with_material(blur_material)
      @blur_rt.unbind

      # Pass 3: Combine with scene
      output_rt.bind
      GL.Clear(GL::COLOR_BUFFER_BIT)

      combine_material.set_runtime_texture("screenTexture", input_rt.color_texture)
      combine_material.set_runtime_texture("ssaoTexture", @blur_rt.color_texture)

      screen_quad.draw_with_material(combine_material)
      output_rt.unbind

      output_rt
    end

    attr_accessor :radius, :bias, :power, :blur_size

    def update_params
      ssao_material.set_float("radius", @radius)
      ssao_material.set_float("bias", @bias)
      ssao_material.set_float("power", @power)
      blur_material.set_int("blurSize", @blur_size)
    end

    private

    def kernel
      @kernel ||= begin
        samples = []
        @kernel_size.times do |i|
          # Random point in hemisphere (tangent space)
          x = rand * 2.0 - 1.0
          y = rand * 2.0 - 1.0
          z = rand # z is always positive (hemisphere)

          # Normalize
          length = Math.sqrt(x**2 + y**2 + z**2)
          x /= length
          y /= length
          z /= length

          # Scale to distribute more samples near origin (accelerating lerp)
          scale = i.to_f / @kernel_size
          scale = lerp(0.1, 1.0, scale * scale)

          samples << Vector[x * scale, y * scale, z * scale]
        end
        samples
      end
    end

    def lerp(a, b, t)
      a + (b - a) * t
    end

    def noise_texture
      @noise_texture ||= begin
        # 4x4 texture of random rotation vectors (tangent space)
        noise_data = []
        16.times do
          noise_data << (rand * 2.0 - 1.0) # x
          noise_data << (rand * 2.0 - 1.0) # y
          noise_data << 0.0                 # z (rotate around z axis)
        end

        tex_buf = ' ' * 4
        GL.GenTextures(1, tex_buf)
        texture = tex_buf.unpack1('L')

        GL.BindTexture(GL::TEXTURE_2D, texture)
        GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGB16F, 4, 4, 0, GL::RGB, GL::FLOAT, noise_data.pack('f*'))
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::NEAREST)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::NEAREST)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::REPEAT)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::REPEAT)
        texture
      end
    end

    def ssao_material
      @ssao_material ||= begin
        material = Engine::Material.create(
          shader: Engine::Shader.create(
            vertex_path: './shaders/fullscreen_vertex.glsl',
            fragment_path: './shaders/post_process/ssao/frag.glsl'
          )
        )

        # Upload kernel samples
        kernel.each_with_index do |sample, i|
          material.set_vec3("samples[#{i}]", sample)
        end
        material.set_int("kernelSize", @kernel_size)
        material.set_float("radius", @radius)
        material.set_float("bias", @bias)
        material.set_float("power", @power)
        material
      end
    end

    def blur_material
      @blur_material ||= begin
        material = Engine::Material.create(
          shader: Engine::Shader.create(
            vertex_path: './shaders/fullscreen_vertex.glsl',
            fragment_path: './shaders/post_process/ssao/blur_frag.glsl'
          )
        )
        material.set_int("blurSize", @blur_size)
        material.set_float("depthThreshold", @depth_threshold)
        material
      end
    end

    def combine_material
      @combine_material ||= Engine::Material.create(
        shader: Engine::Shader.create(
          vertex_path: './shaders/fullscreen_vertex.glsl',
          fragment_path: './shaders/post_process/ssao/combine_frag.glsl'
        )
      )
    end

    def ensure_textures(width, height)
      half_width = width / 2
      half_height = height / 2
      if @ssao_rt.nil? || @ssao_rt.width != half_width || @ssao_rt.height != half_height
        @ssao_rt = RenderTexture.new(half_width, half_height)
        @blur_rt = RenderTexture.new(half_width, half_height)
      end
    end
  end
end
