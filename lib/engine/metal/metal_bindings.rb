# frozen_string_literal: true

require 'fiddle'
require 'fiddle/import'

module Engine
  module Metal
    module ObjC
      extend Fiddle::Importer
      dlload '/usr/lib/libobjc.A.dylib'

      extern 'void* objc_getClass(const char*)'
      extern 'void* sel_registerName(const char*)'

      # We need to handle objc_msgSend manually for variadic args
      OBJC_LIB = Fiddle.dlopen('/usr/lib/libobjc.A.dylib')
      OBJC_MSGSEND_ADDR = OBJC_LIB['objc_msgSend']

      def self.cls(name)
        objc_getClass(name)
      end

      def self.sel(name)
        sel_registerName(name)
      end

      def self.msg(obj, selector, *args)
        sel_ptr = sel(selector)

        # Build argument types: obj, sel, then args
        arg_types = [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP]
        call_args = [obj, sel_ptr]

        args.each do |arg|
          case arg
          when Integer
            arg_types << Fiddle::TYPE_LONG
            call_args << arg
          when Float
            arg_types << Fiddle::TYPE_DOUBLE
            call_args << arg
          when String
            arg_types << Fiddle::TYPE_VOIDP
            call_args << Fiddle::Pointer[arg]
          when Fiddle::Pointer
            arg_types << Fiddle::TYPE_VOIDP
            call_args << arg
          when nil
            arg_types << Fiddle::TYPE_VOIDP
            call_args << Fiddle::Pointer.new(0)
          else
            # Assume it's a pointer-like thing
            arg_types << Fiddle::TYPE_VOIDP
            call_args << arg
          end
        end

        func = Fiddle::Function.new(OBJC_MSGSEND_ADDR, arg_types, Fiddle::TYPE_VOIDP)
        result = func.call(*call_args)
        Fiddle::Pointer.new(result)
      end
    end

    module MetalFramework
      extend Fiddle::Importer
      dlload '/System/Library/Frameworks/Metal.framework/Metal'
      dlload '/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics'

      # Get default device via Objective-C runtime instead of C function
      def self.create_system_default_device
        # MTLCopyAllDevices returns an NSArray of devices, first one is default
        devices = ObjC.msg(ObjC.cls('MTLCopyAllDevicesWithObserver'), 'alloc')
        # Simpler: use the class method on MTLDevice protocol
        # Actually, let's just call the C function through a different approach
        metal_lib = Fiddle.dlopen('/System/Library/Frameworks/Metal.framework/Metal')
        create_device = Fiddle::Function.new(
          metal_lib['MTLCreateSystemDefaultDevice'],
          [],
          Fiddle::TYPE_VOIDP
        )
        create_device.call
      end
    end

    module IOSurfaceFramework
      extend Fiddle::Importer
      dlload '/System/Library/Frameworks/IOSurface.framework/IOSurface'

      extern 'void* IOSurfaceCreate(void*)'
      extern 'int IOSurfaceLock(void*, int, void*)'
      extern 'int IOSurfaceUnlock(void*, int, void*)'
      extern 'void* IOSurfaceGetBaseAddress(void*)'
      extern 'int IOSurfaceGetWidth(void*)'
      extern 'int IOSurfaceGetHeight(void*)'
      extern 'int IOSurfaceGetBytesPerRow(void*)'
    end

    module CoreFoundation
      extend Fiddle::Importer
      dlload '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation'

      extern 'void* CFDictionaryCreateMutable(void*, long, void*, void*)'
      extern 'void CFDictionarySetValue(void*, void*, void*)'
      extern 'void* CFNumberCreate(void*, int, void*)'
      extern 'void CFRelease(void*)'

      # CFNumber types
      CFNUMBER_INT_TYPE = 9
      CFNUMBER_FLOAT_TYPE = 12

      def self.create_int(value)
        ptr = Fiddle::Pointer.malloc(4)
        ptr[0, 4] = [value].pack('i')
        CFNumberCreate(nil, CFNUMBER_INT_TYPE, ptr)
      end
    end

    module OpenGLBridge
      extend Fiddle::Importer
      dlload '/System/Library/Frameworks/OpenGL.framework/OpenGL'

      extern 'int CGLTexImageIOSurface2D(void*, int, int, int, int, int, int, void*, int)'
      extern 'void* CGLGetCurrentContext()'
    end
  end
end
