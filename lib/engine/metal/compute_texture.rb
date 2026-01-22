# frozen_string_literal: true

require_relative 'metal_bindings'
require_relative 'device'

module Engine
  module Metal
    class ComputeTexture
      include Fiddle

      attr_reader :width, :height, :gl_texture, :metal_texture

      # IOSurface property keys
      IOSURFACE_WIDTH = 'IOSurfaceWidth'
      IOSURFACE_HEIGHT = 'IOSurfaceHeight'
      IOSURFACE_BYTES_PER_ELEMENT = 'IOSurfaceBytesPerElement'
      IOSURFACE_BYTES_PER_ROW = 'IOSurfaceBytesPerRow'
      IOSURFACE_ALLOC_SIZE = 'IOSurfaceAllocSize'
      IOSURFACE_PIXEL_FORMAT = 'IOSurfacePixelFormat'

      # Pixel format for RGBA32F
      PIXEL_FORMAT_RGBA32F = 0x52474241 # 'RGBA' as 32-bit int

      def initialize(width, height)
        @width = width
        @height = height
        @device = Device.instance

        create_iosurface
        create_metal_texture
        create_gl_rect_texture
        create_gl_2d_texture
        setup_blit_fbo
      end

      def sync
        Engine::GL.BindFramebuffer(Engine::GL::READ_FRAMEBUFFER, @read_fbo)
        Engine::GL.BindFramebuffer(Engine::GL::DRAW_FRAMEBUFFER, @draw_fbo)

        Engine::GL.BlitFramebuffer(
          0, 0, @width, @height,
          0, 0, @width, @height,
          Engine::GL::COLOR_BUFFER_BIT,
          Engine::GL::NEAREST
        )

        Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, 0)
        Engine::GL.Finish
      end

      private

      def create_iosurface
        props = create_iosurface_properties
        @iosurface = IOSurfaceFramework.IOSurfaceCreate(props)

        if @iosurface.null? || @iosurface.to_i == 0
          raise "Failed to create IOSurface"
        end

        CoreFoundation.CFRelease(props)
      end

      def create_iosurface_properties
        dict = CoreFoundation.CFDictionaryCreateMutable(nil, 0, nil, nil)

        bytes_per_element = 16 # 4 floats * 4 bytes
        bytes_per_row = @width * bytes_per_element
        alloc_size = bytes_per_row * @height

        set_dict_int(dict, IOSURFACE_WIDTH, @width)
        set_dict_int(dict, IOSURFACE_HEIGHT, @height)
        set_dict_int(dict, IOSURFACE_BYTES_PER_ELEMENT, bytes_per_element)
        set_dict_int(dict, IOSURFACE_BYTES_PER_ROW, bytes_per_row)
        set_dict_int(dict, IOSURFACE_ALLOC_SIZE, alloc_size)
        set_dict_int(dict, IOSURFACE_PIXEL_FORMAT, PIXEL_FORMAT_RGBA32F)

        dict
      end

      def set_dict_int(dict, key, value)
        key_str = ObjC.msg(ObjC.cls('NSString'), 'stringWithUTF8String:', key)
        num = CoreFoundation.create_int(value)
        CoreFoundation.CFDictionarySetValue(dict, key_str, num)
      end

      def create_metal_texture
        descriptor = ObjC.msg(ObjC.cls('MTLTextureDescriptor'), 'new')

        # MTLPixelFormatRGBA32Float = 125
        ObjC.msg(descriptor, 'setPixelFormat:', 125)
        ObjC.msg(descriptor, 'setWidth:', @width)
        ObjC.msg(descriptor, 'setHeight:', @height)
        # MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite = 1 | 2 = 3
        ObjC.msg(descriptor, 'setUsage:', 3)
        # MTLStorageModeShared = 0
        ObjC.msg(descriptor, 'setStorageMode:', 0)

        @metal_texture = ObjC.msg(
          @device.device,
          'newTextureWithDescriptor:iosurface:plane:',
          descriptor,
          @iosurface,
          0
        )

        if @metal_texture.null? || @metal_texture.to_i == 0
          raise "Failed to create Metal texture from IOSurface"
        end
      end

      def create_gl_rect_texture
        tex_buf = ' ' * 4
        Engine::GL.GenTextures(1, tex_buf)
        @gl_texture_rect = tex_buf.unpack('L')[0]

        Engine::GL.BindTexture(Engine::GL::TEXTURE_RECTANGLE, @gl_texture_rect)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_RECTANGLE, Engine::GL::TEXTURE_MIN_FILTER, Engine::GL::LINEAR)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_RECTANGLE, Engine::GL::TEXTURE_MAG_FILTER, Engine::GL::LINEAR)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_RECTANGLE, Engine::GL::TEXTURE_WRAP_S, Engine::GL::CLAMP_TO_EDGE)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_RECTANGLE, Engine::GL::TEXTURE_WRAP_T, Engine::GL::CLAMP_TO_EDGE)

        cgl_context = OpenGLBridge.CGLGetCurrentContext()

        result = OpenGLBridge.CGLTexImageIOSurface2D(
          cgl_context,
          Engine::GL::TEXTURE_RECTANGLE,
          Engine::GL::RGBA32F,
          @width,
          @height,
          Engine::GL::RGBA,
          Engine::GL::FLOAT,
          @iosurface,
          0
        )

        raise "Failed to bind IOSurface to GL texture: #{result}" unless result == 0

        Engine::GL.BindTexture(Engine::GL::TEXTURE_RECTANGLE, 0)
      end

      def create_gl_2d_texture
        tex_buf = ' ' * 4
        Engine::GL.GenTextures(1, tex_buf)
        @gl_texture = tex_buf.unpack('L')[0]

        Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, @gl_texture)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MIN_FILTER, Engine::GL::LINEAR)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MAG_FILTER, Engine::GL::LINEAR)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_WRAP_S, Engine::GL::REPEAT)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_WRAP_T, Engine::GL::REPEAT)

        Engine::GL.TexImage2D(Engine::GL::TEXTURE_2D, 0, Engine::GL::RGBA32F, @width, @height, 0, Engine::GL::RGBA, Engine::GL::FLOAT, nil)
        Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, 0)
      end

      def setup_blit_fbo
        read_fbo_buf = ' ' * 4
        Engine::GL.GenFramebuffers(1, read_fbo_buf)
        @read_fbo = read_fbo_buf.unpack('L')[0]

        Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, @read_fbo)
        Engine::GL.FramebufferTexture2D(Engine::GL::FRAMEBUFFER, Engine::GL::COLOR_ATTACHMENT0, Engine::GL::TEXTURE_RECTANGLE, @gl_texture_rect, 0)

        draw_fbo_buf = ' ' * 4
        Engine::GL.GenFramebuffers(1, draw_fbo_buf)
        @draw_fbo = draw_fbo_buf.unpack('L')[0]

        Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, @draw_fbo)
        Engine::GL.FramebufferTexture2D(Engine::GL::FRAMEBUFFER, Engine::GL::COLOR_ATTACHMENT0, Engine::GL::TEXTURE_2D, @gl_texture, 0)

        Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, 0)
      end
    end
  end
end
