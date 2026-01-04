require 'chunky_png'

module Engine
  class Texture
    include Serializable

    attr_reader :texture
    private_class_method :new

    def self.from_serializable_data(data)
      self.for(data[:path], flip: data[:flip] || false)
    end

    def serializable_data
      { path: @relative_path, flip: @flip }
    end

    def initialize(relative_path, full_path, flip)
      @relative_path = relative_path
      @file_path = full_path
      @flip = flip
      @texture = ' ' * 4
      load_texture
    end

    def self.for(path, flip: false)
      full_path = File.expand_path(File.join(GAME_DIR, path))
      texture_cache[[path, flip]] ||= new(path, full_path, flip)
    end

    def self.texture_cache
      @texture_cache ||= {}
    end

    def load_texture
      tex = ' ' * 4
      GL.GenTextures(1, tex)
      @texture = tex.unpack('L')[0]
      GL.BindTexture(GL::TEXTURE_2D, @texture)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::REPEAT)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::REPEAT)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::LINEAR)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::LINEAR)

      image = read_image
      image_data = image.to_rgba_stream
      image_width = image.width
      image_height = image.height

      GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGBA32F, image_width, image_height, 0, GL::RGBA, GL::UNSIGNED_BYTE, image_data)
      GL.GenerateMipmap(GL::TEXTURE_2D)
    end

    def read_image
      if @flip
        ChunkyPNG::Image.from_file(@file_path).flip_horizontally
      else
        ChunkyPNG::Image.from_file(@file_path)
      end
    end
  end
end
