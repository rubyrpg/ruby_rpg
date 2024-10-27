require 'opengl'
require 'glfw'
require 'concurrent'
require 'os'

require_relative 'rendering/render_pipeline'
require_relative 'rendering/instance_renderer'
require_relative 'screenshoter'
require_relative 'input'
require_relative "quaternion"
require_relative 'game_object'
require_relative 'texture'
require_relative 'material'
require_relative 'mesh'
require_relative "font"
require_relative 'path'
require_relative 'polygon_mesh'
require_relative 'importers/obj_file'
require_relative 'tangent_calculator'
require_relative 'shader'
require_relative 'component'
require_relative "camera"
require_relative "window"
require_relative "video_mode"
require_relative "cursor"

require_relative "components/orthographic_camera"
require_relative "components/perspective_camera"
require_relative "components/sprite_renderer"
require_relative "components/ui_sprite_renderer"
require_relative "components/mesh_renderer"
require_relative "components/font_renderer"
require_relative "components/ui_font_renderer"
require_relative "components/point_light"
require_relative "components/direction_light"

require_relative "physics/physics_resolver"
require_relative 'physics/collision'
require_relative "physics/components/sphere_collider"
require_relative "physics/components/cube_collider"
require_relative "physics/components/rigidbody"

if OS.windows?
  GLFW.load_lib(File.expand_path(File.join(__dir__, "..", "..", "glfw-3.4.bin.WIN64", "lib-static-ucrt", "glfw3.dll")))
elsif OS.mac?
  GLFW.load_lib("libglfw.dylib") # Give path to "glfw3.dll (Windows)" or "libglfw.dylib (macOS)" if needed
end
GLFW.Init

module Engine
  def self.start(base_dir:, &first_frame_block)
    load(base_dir)
    return if ENV["BUILDING"] == "true"

    open_window
    main_game_loop(&first_frame_block)
    terminate
  end

  def self.engine_started?
    @engine_started
  end

  def self.load(base_dir)
    base_dir = File.expand_path(base_dir)
    Dir[File.join(base_dir, "components", "**/*.rb")].each { |file| require file }
    Dir[File.join(base_dir, "game_objects", "**/*.rb")].each { |file| require file }
  end

  def self.open_window
    @old_time = Time.now
    @time = Time.now
    @key_callback = create_key_callbacks # This must be an instance variable to prevent garbage collection

    Window.create_window
    GLFW.MakeContextCurrent(Window.window)
    GLFW.SetKeyCallback(Window.window, @key_callback)
    GL.load_lib

    set_opengl_blend_mode
    @engine_started = true
    GL.ClearColor(0.0, 0.0, 0.0, 1.0)

    GL.Enable(GL::CULL_FACE)
    GL.CullFace(GL::BACK)

    GLFW.SwapInterval(0)

    Cursor.hide
  end

  def self.main_game_loop(&first_frame_block)
    @game_stopped = false
    @old_time = Time.now
    @time = Time.now
    @fps = 0
    Window.get_framebuffer_size
    GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)

    until GLFW.WindowShouldClose(Window.window) == GLFW::TRUE || @game_stopped
      if first_frame_block
        first_frame_block.call
        first_frame_block = nil
      end

      @old_time = @time || Time.now
      @time = Time.now
      delta_time = @time - @old_time

      print_fps(delta_time)
      Physics::PhysicsResolver.resolve
      GameObject.update_all(delta_time)

      @swap_buffers_promise.wait! if @swap_buffers_promise
      GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
      GL.Enable(GL::DEPTH_TEST)
      GL.DepthFunc(GL::LESS)

      Rendering::RenderPipeline.draw unless @game_stopped
      GL.Disable(GL::DEPTH_TEST)
      GameObject.render_ui(delta_time)

      if Screenshoter.scheduled_screenshot
        Screenshoter.take_screenshot
      end

      Window.get_framebuffer_size

      if OS.windows?
        GLFW.SwapBuffers(Window.window)
      else
        @swap_buffers_promise = Concurrent::Promise.new do
          GLFW.SwapBuffers(Window.window)
        end
        @swap_buffers_promise.execute
      end

      Engine::Input.update_key_states
      GLFW.PollEvents
    end
  end

  def self.fps
    @fps
  end

  def self.terminate
    GLFW.DestroyWindow(Window.window)
    GLFW.Terminate
  end

  def self.close
    GameObject.destroy_all
    GLFW.SetWindowShouldClose(Window.window, 1)
  end

  def self.stop_game
    @game_stopped = true
    @swap_buffers_promise.wait! if @swap_buffers_promise && !@swap_buffers_promise.complete?
    GameObject.destroy_all
  end

  # Hit a breakpoint within the context of where the breakpoint is defined, assuming a block is passed
  # with a `binding.pry` (or an alternative debugger), otherwise hit a breakpoint within this method.
  def self.breakpoint(&block)
    orig_fullscreen = Window.full_screen?
    if orig_fullscreen
      Window.set_to_windowed
      GLFW.PollEvents # Required to trigger the switch from fullscreen to windowed within this breakpoint
    end

    orig_cursor_mode = Cursor.get_input_mode
    Cursor.enable

    block_given? ? yield : binding.pry
    Cursor.restore_input_mode(orig_cursor_mode)
    Window.set_to_full_screen if orig_fullscreen
    Window.focus_window

    # Reset the time, otherwise delta_time will be off for the next frame, and teleporting occurs
    @time = Time.now
  end

  private

  def self.print_fps(delta_time)
    @time_since_last_fps_print = (@time_since_last_fps_print || 0) + delta_time
    @frame = (@frame || 0) + 1
    if @time_since_last_fps_print > 1
      @fps = @frame / @time_since_last_fps_print
      puts "FPS: #{@fps}"
      @time_since_last_fps_print = 0
      @frame = 0
    end
  end

  def self.set_opengl_blend_mode
    GL.Enable(GL::BLEND)
    GL.BlendFunc(GL::SRC_ALPHA, GL::ONE_MINUS_SRC_ALPHA)
  end

  def self.create_key_callbacks
    GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
      Input.key_callback(key, action)
    end
  end

  def self.debug_opengl_call
    errors = []
    until GL.GetError == 0; end
    yield
    until (error = GL.GetError) == 0
      errors += error.to_s(16)
    end
  end

  def self.print_opengl_version
    puts "OpenGL Version: #{GL.GetString(GL::VERSION)}"
    puts "GLSL Version: #{GL.GetString(GL::SHADING_LANGUAGE_VERSION)}"
  end
end
