# frozen_string_literal: true

module Engine
  def self.start(&first_frame_block)
    Engine::AutoLoader.load
    return if ENV["BUILDING"] == "true"

    open_window
    main_game_loop(&first_frame_block)
    terminate
  end

  def self.engine_started?
    @engine_started
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

  def self.close
    GameObject.destroy_all
    GLFW.SetWindowShouldClose(Window.window, 1)
  end

  def self.stop_game
    @game_stopped = true
    @swap_buffers_promise.wait! if @swap_buffers_promise && !@swap_buffers_promise.complete?
    GameObject.destroy_all
  end

  private

  def self.terminate
    GLFW.DestroyWindow(Window.window)
    GLFW.Terminate
  end

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
end
