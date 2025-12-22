# frozen_string_literal: true

require_relative 'device'

module Engine
  module Metal
    class ComputeShader
      include Fiddle

      def initialize(shader_path)
        @device = Device.instance
        @uniform_buffer_data = {}

        path = File.expand_path(File.join(GAME_DIR, shader_path))
        source = File.read(path)

        @library = @device.new_library_with_source(source)
        @pipeline = @device.new_compute_pipeline(@library, 'computeMain')

        # Get thread execution width for optimal dispatch
        @thread_width = ObjC.msg(@pipeline, 'threadExecutionWidth').to_i
        @thread_height = ObjC.msg(@pipeline, 'maxTotalThreadsPerThreadgroup').to_i / @thread_width
      end

      def dispatch(width, height, depth, textures: [], floats: {}, ints: {})
        command_buffer = @device.new_command_buffer
        encoder = ObjC.msg(command_buffer, 'computeCommandEncoder')

        # Set the pipeline state
        ObjC.msg(encoder, 'setComputePipelineState:', @pipeline)

        # Set textures (extract metal_texture from ComputeTexture objects)
        textures.each_with_index do |texture, index|
          next if texture.nil?
          metal_tex = texture.respond_to?(:metal_texture) ? texture.metal_texture : texture
          ObjC.msg(encoder, 'setTexture:atIndex:', metal_tex, index)
        end

        # Create uniform buffer with floats and ints
        if floats.any? || ints.any?
          uniform_data = create_uniform_buffer(floats, ints)
          uniform_buffer = create_metal_buffer(uniform_data)
          ObjC.msg(encoder, 'setBuffer:offset:atIndex:', uniform_buffer, 0, 0)
        end

        # Calculate thread groups
        # Use dispatchThreads for simpler dispatch (Metal 2.0+)
        threads = create_mtl_size_ptr(width, height, depth)
        threads_per_group = create_mtl_size_ptr(@thread_width, @thread_height, 1)

        # Use objc_msgSend_stret variant for struct-passing methods
        dispatch_threads(encoder, threads, threads_per_group)

        ObjC.msg(encoder, 'endEncoding')
        ObjC.msg(command_buffer, 'commit')
        ObjC.msg(command_buffer, 'waitUntilCompleted')

        # Sync textures to make results available for OpenGL rendering
        textures.each { |tex| tex.sync if tex.respond_to?(:sync) }
      end

      private

      def create_uniform_buffer(floats, ints)
        # Pack uniforms into a byte buffer
        # Layout: all floats first, then ints (aligned to 4 bytes)
        data = []
        floats.each_value { |v| data.concat([v].pack('f').bytes) }
        ints.each_value { |v| data.concat([v].pack('i').bytes) }
        data.pack('C*')
      end

      def create_metal_buffer(data)
        data_ptr = Pointer[data]
        ObjC.msg(
          @device.device,
          'newBufferWithBytes:length:options:',
          data_ptr,
          data.bytesize,
          0 # MTLResourceStorageModeShared
        )
      end

      def create_mtl_size_ptr(width, height, depth)
        # MTLSize is a struct { width, height, depth } - 3 NSUInteger (64-bit each)
        data = [width, height, depth].pack('Q3')
        ptr = Pointer.malloc(24)
        ptr[0, 24] = data
        ptr
      end

      def dispatch_threads(encoder, threads, threads_per_group)
        # dispatchThreads:threadsPerThreadgroup: passes MTLSize structs
        # On ARM64, structs > 16 bytes are passed by pointer in x8
        # We need to use objc_msgSend directly with proper calling convention

        sel = ObjC.sel('dispatchThreads:threadsPerThreadgroup:')

        # Build a function that takes the struct values directly
        # ARM64 ABI: first 8 args in x0-x7, structs by value if <= 16 bytes, else by pointer
        # MTLSize is 24 bytes, so passed by pointer

        func = Fiddle::Function.new(
          ObjC::OBJC_MSGSEND_ADDR,
          [
            Fiddle::TYPE_VOIDP,  # self (encoder)
            Fiddle::TYPE_VOIDP,  # _cmd (selector)
            Fiddle::TYPE_VOIDP,  # threads (pointer to MTLSize)
            Fiddle::TYPE_VOIDP   # threadsPerThreadgroup (pointer to MTLSize)
          ],
          Fiddle::TYPE_VOID
        )

        func.call(encoder, sel, threads, threads_per_group)
      end
    end
  end
end
