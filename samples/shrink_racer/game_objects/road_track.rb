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
    ROAD_PARTS = {
      road: "create_straight_road",
      corner: "create_corner_road",
      cross: "create_cross_road",
      t_junction: "create_t_junction_road",
      bridge: "create_bridge_road",
      pond: "create_pond"
    }

    TRACKS = {
      track_1: { file: "Road 1.csv" },
      track_2: { file: "Road 2.csv" },
      track_3: { file: "Road 3.csv", start_pos: Vector[63, 0.6, 39], start_rot: Vector[0, 90, 0] },
    }

    def self.create(track)
      track = load_track(File.join("assets", track[:file]))
      track.each_with_index do |row, x|
        row.reverse.each_with_index do |cell, z|
          pos = Vector[x * CELL_SIZE, 0, z * CELL_SIZE]
          rot = DIRECTIONS[cell[1]] || DIRECTIONS[:north]
          type = ROAD_PARTS[cell[0]]
          if type
            RoadTile.send(type, pos, rot)
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
      CSV.read(File.join(GAME_DIR, file)).map do |row|
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
