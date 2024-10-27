# frozen_string_literal: true

require "json"

module Engine
  class Font
    TEXTURE_SIZE = 1024
    GLYPH_COUNT = 16
    CELL_SIZE = TEXTURE_SIZE / GLYPH_COUNT

    def initialize(font_file_path)
      @font_file_path = font_file_path
    end

    def texture
      @texture ||=
        begin
          path = File.expand_path(File.join(ROOT, "_imported", @font_file_path.gsub(".ttf", ".png")))
          Engine::Texture.for(path)
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
      font_path = File.expand_path(File.join(ROOT, "_imported", @font_file_path.gsub(".ttf", ".json")))
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
