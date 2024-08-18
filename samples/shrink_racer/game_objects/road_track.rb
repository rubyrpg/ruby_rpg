# frozen_string_literal: true

require "csv"

module ShrinkRacer
  module RoadTrack
    CELL_SIZE = 3
    DIRECTIONS = {
      north: Vector[0, 0, 0],
      east: Vector[0, 90, 0],
      south: Vector[0, 180, 0],
      west: Vector[0, 270, 0],
    }

    def self.create
      track = RoadTrack.load_track(File.join(ASSETS_DIR, "track.csv"))
      track.each_with_index do |row, z|
        row.each_with_index do |cell, x|
          pos = Vector[x * CELL_SIZE, 0, z * CELL_SIZE]
          rot = DIRECTIONS[cell[1]] || DIRECTIONS[:north]
          case cell[0]
          when :road
            RoadTile.create_straight_road(pos, rot)
          when :corner
            RoadTile.create_corner_road(pos, rot)
          else
            RoadTile.create_grass(pos, rot)
          end
        end
      end
    end

    def self.create_gallery
      1.upto(302) do |i|
        RoadTile.create("%03d" % i, Vector[i * 5, 0, 0], Vector[0, 0, 0])
        Text.create(Vector[i * 5 + 1.5, -1, 0], Vector[0, 0, 0], 1, "%03d" % i)
      end
    end

    def self.load_track(file)
      CSV.read(file).map do |row|
        row.map do |cell|
          if cell.nil? || cell.empty?
            [nil, nil]
          else
            type, dir = cell.split("|")
            [type.to_sym, dir.to_sym]
          end
        end
      end
    end
  end
end