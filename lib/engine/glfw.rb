# frozen_string_literal: true

require 'glfw_native'
require 'fiddle'
require 'fiddle/import'

module GLFW
  # GLFW boolean constants
  TRUE = 1
  FALSE = 0

  # GLFW key action constants
  RELEASE = 0
  PRESS = 1
  REPEAT = 2

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

  # Keyboard keys
  KEY_SPACE = 32
  KEY_APOSTROPHE = 39
  KEY_COMMA = 44
  KEY_MINUS = 45
  KEY_PERIOD = 46
  KEY_SLASH = 47
  KEY_0 = 48
  KEY_1 = 49
  KEY_2 = 50
  KEY_3 = 51
  KEY_4 = 52
  KEY_5 = 53
  KEY_6 = 54
  KEY_7 = 55
  KEY_8 = 56
  KEY_9 = 57
  KEY_SEMICOLON = 59
  KEY_EQUAL = 61
  KEY_A = 65
  KEY_B = 66
  KEY_C = 67
  KEY_D = 68
  KEY_E = 69
  KEY_F = 70
  KEY_G = 71
  KEY_H = 72
  KEY_I = 73
  KEY_J = 74
  KEY_K = 75
  KEY_L = 76
  KEY_M = 77
  KEY_N = 78
  KEY_O = 79
  KEY_P = 80
  KEY_Q = 81
  KEY_R = 82
  KEY_S = 83
  KEY_T = 84
  KEY_U = 85
  KEY_V = 86
  KEY_W = 87
  KEY_X = 88
  KEY_Y = 89
  KEY_Z = 90
  KEY_LEFT_BRACKET = 91
  KEY_BACKSLASH = 92
  KEY_RIGHT_BRACKET = 93
  KEY_GRAVE_ACCENT = 96
  KEY_ESCAPE = 256
  KEY_ENTER = 257
  KEY_TAB = 258
  KEY_BACKSPACE = 259
  KEY_INSERT = 260
  KEY_DELETE = 261
  KEY_RIGHT = 262
  KEY_LEFT = 263
  KEY_DOWN = 264
  KEY_UP = 265
  KEY_PAGE_UP = 266
  KEY_PAGE_DOWN = 267
  KEY_HOME = 268
  KEY_END = 269
  KEY_CAPS_LOCK = 280
  KEY_SCROLL_LOCK = 281
  KEY_NUM_LOCK = 282
  KEY_PRINT_SCREEN = 283
  KEY_PAUSE = 284
  KEY_F1 = 290
  KEY_F2 = 291
  KEY_F3 = 292
  KEY_F4 = 293
  KEY_F5 = 294
  KEY_F6 = 295
  KEY_F7 = 296
  KEY_F8 = 297
  KEY_F9 = 298
  KEY_F10 = 299
  KEY_F11 = 300
  KEY_F12 = 301
  KEY_LEFT_SHIFT = 340
  KEY_LEFT_CONTROL = 341
  KEY_LEFT_ALT = 342
  KEY_LEFT_SUPER = 343
  KEY_RIGHT_SHIFT = 344
  KEY_RIGHT_CONTROL = 345
  KEY_RIGHT_ALT = 346
  KEY_RIGHT_SUPER = 347

  # Mouse buttons
  MOUSE_BUTTON_1 = 0
  MOUSE_BUTTON_2 = 1
  MOUSE_BUTTON_3 = 2
  MOUSE_BUTTON_4 = 3
  MOUSE_BUTTON_5 = 4
  MOUSE_BUTTON_6 = 5
  MOUSE_BUTTON_7 = 6
  MOUSE_BUTTON_8 = 7
  MOUSE_BUTTON_LEFT = MOUSE_BUTTON_1
  MOUSE_BUTTON_RIGHT = MOUSE_BUTTON_2
  MOUSE_BUTTON_MIDDLE = MOUSE_BUTTON_3

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
