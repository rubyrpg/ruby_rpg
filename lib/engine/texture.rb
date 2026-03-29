require 'chunky_png'

module Engine
  class Texture
    include Serializable

    attr_reader :texture, :source

    def self.from_serializable_data(data)
      self.for(data[:path], source: (data[:source] || :game).to_sym)
    end

    def serializable_data
      { path: @relative_path, source: @source }
    end

    def awake
      @texture = ' ' * 4
      load_texture
    end

    def self.for(path, source: :game, **_)
      full_path = if source == :engine
        File.expand_path(File.join(ENGINE_DIR, "assets", path))
      else
        File.expand_path(File.join(GAME_DIR, path))
      end
      texture_cache[[path, source]] ||= create(relative_path: path, file_path: full_path, source: source)
    end

    def self.texture_cache
      @texture_cache ||= {}
    end

    def load_texture
      tex = ' ' * 4
      Engine::GL.GenTextures(1, tex)
      @texture = tex.unpack('L')[0]
      Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, @texture)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_WRAP_S, Engine::GL::REPEAT)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_WRAP_T, Engine::GL::REPEAT)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MIN_FILTER, Engine::GL::LINEAR)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MAG_FILTER, Engine::GL::LINEAR)

      image = ChunkyPNG::Image.from_file(@file_path)
      image_data = image.to_rgba_stream
      image_width = image.width
      image_height = image.height

      # Flip rows vertically so textures follow OpenGL convention (V=0 at bottom)
      row_size = image_width * 4
      flipped = String.new(capacity: image_data.bytesize)
      (image_height - 1).downto(0) do |row|
        flipped << image_data.byteslice(row * row_size, row_size)
      end

      Engine::GL.TexImage2D(Engine::GL::TEXTURE_2D, 0, Engine::GL::RGBA32F, image_width, image_height, 0, Engine::GL::RGBA, Engine::GL::UNSIGNED_BYTE, flipped)
      Engine::GL.GenerateMipmap(Engine::GL::TEXTURE_2D)
    end
  end
end
