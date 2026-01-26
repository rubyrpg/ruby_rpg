# frozen_string_literal: true

require 'glfw_native'
require 'fiddle'
require 'fiddle/import'

module GLFW
  # GLFW boolean constants
  TRUE = 1
  FALSE = 0

  # Window hints
  CONTEXT_VERSION_MAJOR = 0x00022002
  CONTEXT_VERSION_MINOR = 0x00022003
  OPENGL_FORWARD_COMPAT = 0x00022006
  OPENGL_PROFILE = 0x00022008
  DECORATED = 0x00020005
  AUTO_ICONIFY = 0x00020006

  # OpenGL profiles
  OPENGL_CORE_PROFILE = 0x00032001

  # Special value for "don't care"
  DONT_CARE = -1

  # Cursor input mode
  CURSOR = 0x00033001
  CURSOR_NORMAL = 0x00034001
  CURSOR_HIDDEN = 0x00034002
  CURSOR_DISABLED = 0x00034003

  # GLFWvidmode struct for video mode handling
  # Matches the C struct layout:
  #   int width, height, redBits, greenBits, blueBits, refreshRate
  GLFWvidmode = Fiddle::Importer.struct([
    'int width',
    'int height',
    'int redBits',
    'int greenBits',
    'int blueBits',
    'int refreshRate'
  ])

  class << self
    def load_lib(path)
      GLFWNative.load_lib(path)
    end

    def Init
      GLFWNative.init
    end

    def Terminate
      GLFWNative.terminate
    end

    def CreateWindow(width, height, title, monitor, share)
      GLFWNative.create_window(width, height, title, monitor, share)
    end

    def DestroyWindow(window)
      GLFWNative.destroy_window(window)
    end

    def WindowHint(hint, value)
      GLFWNative.window_hint(hint, value)
    end

    def SetWindowAttrib(window, attrib, value)
      GLFWNative.set_window_attrib(window, attrib, value)
    end

    def SetWindowTitle(window, title)
      GLFWNative.set_window_title(window, title)
    end

    def SetWindowMonitor(window, monitor, xpos, ypos, width, height, refresh_rate)
      GLFWNative.set_window_monitor(window, monitor, xpos, ypos, width, height, refresh_rate)
    end

    def WindowShouldClose(window)
      GLFWNative.window_should_close(window)
    end

    def SetWindowShouldClose(window, value)
      GLFWNative.set_window_should_close(window, value)
    end

    def FocusWindow(window)
      GLFWNative.focus_window(window)
    end

    def MakeContextCurrent(window)
      GLFWNative.make_context_current(window)
    end

    def GetFramebufferSize(window, width_buf, height_buf)
      GLFWNative.get_framebuffer_size(window, width_buf, height_buf)
    end

    def PollEvents
      GLFWNative.poll_events
    end

    def SwapBuffers(window)
      GLFWNative.swap_buffers(window)
    end

    def SwapInterval(interval)
      GLFWNative.swap_interval(interval)
    end

    def SetKeyCallback(window, callback)
      GLFWNative.set_key_callback(window, callback)
    end

    def SetCursorPosCallback(window, callback)
      GLFWNative.set_cursor_pos_callback(window, callback)
    end

    def SetMouseButtonCallback(window, callback)
      GLFWNative.set_mouse_button_callback(window, callback)
    end

    def GetPrimaryMonitor
      GLFWNative.get_primary_monitor
    end

    def GetVideoMode(monitor)
      GLFWNative.get_video_mode(monitor)
    end

    def GetVideoModes(monitor, count_buf)
      GLFWNative.get_video_modes(monitor, count_buf)
    end

    def SetInputMode(window, mode, value)
      GLFWNative.set_input_mode(window, mode, value)
    end

    def GetInputMode(window, mode)
      GLFWNative.get_input_mode(window, mode)
    end

    # create_callback is now a no-op that just returns the proc
    # The native extension handles Ruby procs directly
    def create_callback(type, &block)
      block
    end
  end
end
