# frozen_string_literal: true
require 'json'

module Engine
  class FontImporter
    TEXTURE_SIZE = 1024
    GLYPH_COUNT = 16
    CELL_SIZE = TEXTURE_SIZE / GLYPH_COUNT

    attr_reader :source, :destination_image, :destination_metrics

    def initialize(source, destination_image, destination_metrics)
      @source = source
      @destination_image = destination_image
      @destination_metrics = destination_metrics
    end

    def import
      image = Magick::Image.new(TEXTURE_SIZE, TEXTURE_SIZE,) do |options|
        options.background_color = "transparent"
      end
      font_metrics = {}

      draw = Magick::Draw.new
      (0...GLYPH_COUNT).each do |x|
        (0...GLYPH_COUNT).each do |y|
          index = x * GLYPH_COUNT + y
          next if index >= 255
          character = character(index)
          write_character(character, draw, image, coord(x), coord(y))

          metric = draw.get_type_metrics(image, character)
          if character.to_s == " "
            font_metrics[index] = { width: metric.max_advance / 4.0 }
          else
            font_metrics[index] = { width: metric.width }
          end
        end
      end

      FileUtils.mkdir_p(File.dirname(destination_image)) unless File.directory?(File.dirname(destination_image))
      image.write(destination_image)

      File.write(destination_metrics, font_metrics.to_json)
    end

    private

    def write_character(character, draw, image, x, y)
      font_path = File.expand_path(source)

      draw.annotate(image, CELL_SIZE, CELL_SIZE, x, y, character) do |_|
        draw.gravity = Magick::WestGravity
        draw.pointsize = CELL_SIZE - 5
        draw.font = font_path
        draw.fill = "white"
        image.format = "PNG"
      end
    end

    def character(index)
      (index + 1).chr
    end

    def coord(x)
      x * CELL_SIZE
    end
  end
end
