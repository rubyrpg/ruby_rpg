# frozen_string_literal: true

require_relative 'metal_bindings'

module Engine
  module Metal
    class Device
      include Fiddle

      attr_reader :device, :command_queue

      def self.instance
        @instance ||= new
      end

      def initialize
        @device = MetalFramework.create_system_default_device
        raise "Failed to create Metal device" if @device.null?

        @command_queue = ObjC.msg(@device, 'newCommandQueue')
        raise "Failed to create command queue" if @command_queue.null?
      end

      def new_library_with_source(source)
        # Create NSString from source
        ns_string_class = ObjC.cls('NSString')
        source_nsstring = ObjC.msg(
          ns_string_class,
          'stringWithUTF8String:',
          source
        )

        # Create error pointer
        error_ptr = Pointer.malloc(8)
        error_ptr[0, 8] = [0].pack('Q')

        # Compile the library
        library = ObjC.msg(
          @device,
          'newLibraryWithSource:options:error:',
          source_nsstring,
          nil,
          error_ptr
        )

        if library.null?
          error = Pointer.new(error_ptr[0, 8].unpack('Q')[0])
          unless error.null?
            desc = ObjC.msg(error, 'localizedDescription')
            utf8 = ObjC.msg(desc, 'UTF8String')
            raise "Metal shader compilation failed: #{utf8.to_s}"
          end
          raise "Metal shader compilation failed with unknown error"
        end

        library
      end

      def new_compute_pipeline(library, function_name)
        # Get function from library
        func_name_nsstring = ObjC.msg(
          ObjC.cls('NSString'),
          'stringWithUTF8String:',
          function_name
        )
        function = ObjC.msg(library, 'newFunctionWithName:', func_name_nsstring)
        raise "Failed to find function '#{function_name}'" if function.null?

        # Create compute pipeline
        error_ptr = Pointer.malloc(8)
        error_ptr[0, 8] = [0].pack('Q')

        pipeline = ObjC.msg(
          @device,
          'newComputePipelineStateWithFunction:error:',
          function,
          error_ptr
        )

        if pipeline.null?
          error = Pointer.new(error_ptr[0, 8].unpack('Q')[0])
          unless error.null?
            desc = ObjC.msg(error, 'localizedDescription')
            utf8 = ObjC.msg(desc, 'UTF8String')
            raise "Failed to create compute pipeline: #{utf8.to_s}"
          end
          raise "Failed to create compute pipeline with unknown error"
        end

        pipeline
      end

      def new_command_buffer
        ObjC.msg(@command_queue, 'commandBuffer')
      end
    end
  end
end
