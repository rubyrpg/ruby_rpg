# frozen_string_literal: true

require "json"

module Engine
  class Font
    include Serializable

    attr_reader :font_file_path, :source

    TEXTURE_SIZE = 1024
    GLYPH_COUNT = 16
    CELL_SIZE = TEXTURE_SIZE / GLYPH_COUNT

    def self.for(font_file_path, source: :game)
      cache_key = [font_file_path, source]
      font_cache[cache_key] ||= create(font_file_path: font_file_path, source: source)
    end

    def self.font_cache
      @font_cache ||= {}
    end

    def self.open_sans
      self.for("OpenSans-Regular.ttf", source: :engine)
    end

    def self.noto_serif
      self.for("NotoSerif-Regular.ttf", source: :engine)
    end

    def self.jetbrains_mono
      self.for("JetBrainsMono-Regular.ttf", source: :engine)
    end

    def self.press_start_2p
      self.for("PressStart2P-Regular.ttf", source: :engine)
    end

    def self.bangers
      self.for("Bangers-Regular.ttf", source: :engine)
    end

    def self.caveat
      self.for("Caveat-Regular.ttf", source: :engine)
    end

    def self.oswald
      self.for("Oswald-Regular.ttf", source: :engine)
    end

    def self.from_serializable_data(data)
      self.for(data[:font_file_path], source: (data[:source] || :game).to_sym)
    end

    def serializable_data
      { font_file_path: @font_file_path, source: @source }
    end

    def texture
      @texture ||=
        begin
          path = File.join("_imported", @font_file_path.gsub(".ttf", ".png"))
          Engine::Texture.for(path, source: @source)
        end
    end

    def vertex_data(string)
      text_indices = string_indices(string)
      offsets = string_offsets(string)
      text_indices.zip(offsets).flatten
    end

    def string_indices(string)
      string.chars.reject{|c| c == "\n"}.map { |char| index_table[char] }
    end

    def string_offsets(string)
      offsets = []
      scale_factor = 1 / (1024.0 * 2)
      horizontal_offset = 0.0
      vertical_offset = 0.0
      font_path = resolve_font_json_path
      font_metrics = JSON.parse File.read(font_path)
      string.chars.each do |char|
        if char == "\n"
          vertical_offset -= 1.0
          horizontal_offset = 0.0
          next
        end
        offsets << [horizontal_offset, vertical_offset]
        horizontal_offset += 30 * scale_factor * font_metrics[index_table[char].to_s]["width"]
      end
      offsets
    end

    def resolve_font_json_path
      if @source == :engine
        File.expand_path(File.join(ENGINE_DIR, "assets", "_imported", @font_file_path.gsub(".ttf", ".json")))
      else
        File.expand_path(File.join(GAME_DIR, "_imported", @font_file_path.gsub(".ttf", ".json")))
      end
    end

    private

    def character(index)
      (index + 1).chr
    end

    def index_table
      @index_table ||=
        begin
          hash = {}
          GLYPH_COUNT.times do |x|
            GLYPH_COUNT.times.each do |y|
              index = x * GLYPH_COUNT + y
              next if index >= 255
              character = character(index)
              hash[character] = index
            end
          end
          hash
        end
    end
  end
end
