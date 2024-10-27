# frozen_string_literal: true

module Engine
  # https://www.glfw.org/docs/latest/struct_g_l_f_wvidmode.html
  # https://www.glfw.org/docs/latest/monitor_guide.html#monitor_modes
  class VideoMode
    class << self
      def current_video_mode(monitor: Window.primary_monitor)
        video_mode_helper(GLFW.GetVideoMode(monitor), 0)
      end

      # Returns an array of video modes
      def get_video_modes(monitor: Window.primary_monitor)
        count_pointer = ' ' * Fiddle::SIZEOF_INT
        modes_pointer = GLFW.GetVideoModes(monitor, count_pointer)
        count = count_pointer.unpack1('L')

        supported_video_modes = []
        count.times do |i|
          supported_video_modes << video_mode_helper(modes_pointer, i)
        end
        supported_video_modes
      end

      def print_video_mode(mode)
        GLFW::GLFWvidmode.members.map(&:to_sym).map do |attr|
          puts "#{attr}: #{mode.send(attr)}"
        end
        puts
      end

      def video_mode_helper(mode_pointer, index)
        GLFW::GLFWvidmode.new(mode_pointer + index * GLFW::GLFWvidmode.size)
      end
    end
  end
end
