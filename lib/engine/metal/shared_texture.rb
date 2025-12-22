# frozen_string_literal: true

require_relative 'metal_bindings'
require_relative 'device'

module Engine
  module Metal
    class SharedTexture
      include Fiddle

      # gl_texture_2d is the regular TEXTURE_2D for use with existing shaders
      # gl_texture_rect is the TEXTURE_RECTANGLE backed by IOSurface
      attr_reader :gl_texture_2d, :gl_texture_rect, :metal_texture, :width, :height

      # Alias for compatibility - returns the usable 2D texture
      def gl_texture
        @gl_texture_2d
      end

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

      # Call this after Metal compute to copy RECT texture to 2D texture
      def blit_to_2d
        GL.BindFramebuffer(GL::READ_FRAMEBUFFER, @read_fbo)
        GL.BindFramebuffer(GL::DRAW_FRAMEBUFFER, @draw_fbo)

        GL.BlitFramebuffer(
          0, 0, @width, @height,
          0, 0, @width, @height,
          GL::COLOR_BUFFER_BIT,
          GL::NEAREST
        )

        GL.BindFramebuffer(GL::FRAMEBUFFER, 0)

        # Ensure GL operations complete for proper Metal/GL synchronization
        GL.Finish
      end

      private

      def create_iosurface
        # Create properties dictionary
        props = create_iosurface_properties
        @iosurface = IOSurfaceFramework.IOSurfaceCreate(props)

        if @iosurface.null? || @iosurface.to_i == 0
          raise "Failed to create IOSurface"
        end

        CoreFoundation.CFRelease(props)
      end

      def create_iosurface_properties
        # Create mutable dictionary
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
        # Create texture descriptor
        descriptor = ObjC.msg(ObjC.cls('MTLTextureDescriptor'), 'new')

        # MTLPixelFormatRGBA32Float = 125
        ObjC.msg(descriptor, 'setPixelFormat:', 125)
        ObjC.msg(descriptor, 'setWidth:', @width)
        ObjC.msg(descriptor, 'setHeight:', @height)
        # MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite = 1 | 2 = 3
        ObjC.msg(descriptor, 'setUsage:', 3)
        # MTLStorageModeShared = 0
        ObjC.msg(descriptor, 'setStorageMode:', 0)

        # Create texture from IOSurface
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
        # Generate GL texture for RECTANGLE (IOSurface-backed)
        tex_buf = ' ' * 4
        GL.GenTextures(1, tex_buf)
        @gl_texture_rect = tex_buf.unpack('L')[0]

        # Bind as TEXTURE_RECTANGLE (required for IOSurface)
        GL.BindTexture(GL::TEXTURE_RECTANGLE, @gl_texture_rect)

        GL.TexParameteri(GL::TEXTURE_RECTANGLE, GL::TEXTURE_MIN_FILTER, GL::LINEAR)
        GL.TexParameteri(GL::TEXTURE_RECTANGLE, GL::TEXTURE_MAG_FILTER, GL::LINEAR)
        GL.TexParameteri(GL::TEXTURE_RECTANGLE, GL::TEXTURE_WRAP_S, GL::CLAMP_TO_EDGE)
        GL.TexParameteri(GL::TEXTURE_RECTANGLE, GL::TEXTURE_WRAP_T, GL::CLAMP_TO_EDGE)

        # Bind IOSurface to GL texture
        cgl_context = OpenGLBridge.CGLGetCurrentContext()

        result = OpenGLBridge.CGLTexImageIOSurface2D(
          cgl_context,
          GL::TEXTURE_RECTANGLE,
          GL::RGBA32F,
          @width,
          @height,
          GL::RGBA,
          GL::FLOAT,
          @iosurface,
          0
        )

        raise "Failed to bind IOSurface to GL texture: #{result}" unless result == 0

        GL.BindTexture(GL::TEXTURE_RECTANGLE, 0)
      end

      def create_gl_2d_texture
        # Generate regular TEXTURE_2D for use with existing shaders
        tex_buf = ' ' * 4
        GL.GenTextures(1, tex_buf)
        @gl_texture_2d = tex_buf.unpack('L')[0]

        GL.BindTexture(GL::TEXTURE_2D, @gl_texture_2d)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::LINEAR)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::LINEAR)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::REPEAT)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::REPEAT)

        # Allocate storage
        GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGBA32F, @width, @height, 0, GL::RGBA, GL::FLOAT, nil)

        GL.BindTexture(GL::TEXTURE_2D, 0)
      end

      def setup_blit_fbo
        # Create FBO for reading from RECT texture
        read_fbo_buf = ' ' * 4
        GL.GenFramebuffers(1, read_fbo_buf)
        @read_fbo = read_fbo_buf.unpack('L')[0]

        GL.BindFramebuffer(GL::FRAMEBUFFER, @read_fbo)
        GL.FramebufferTexture2D(GL::FRAMEBUFFER, GL::COLOR_ATTACHMENT0, GL::TEXTURE_RECTANGLE, @gl_texture_rect, 0)

        # Create FBO for writing to 2D texture
        draw_fbo_buf = ' ' * 4
        GL.GenFramebuffers(1, draw_fbo_buf)
        @draw_fbo = draw_fbo_buf.unpack('L')[0]

        GL.BindFramebuffer(GL::FRAMEBUFFER, @draw_fbo)
        GL.FramebufferTexture2D(GL::FRAMEBUFFER, GL::COLOR_ATTACHMENT0, GL::TEXTURE_2D, @gl_texture_2d, 0)

        GL.BindFramebuffer(GL::FRAMEBUFFER, 0)
      end
    end
  end
end
