# frozen_string_literal: true

module Engine
  module AutoLoader
    def self.load(load_path = nil)
      base_dir = File.expand_path(load_path || File.dirname($PROGRAM_NAME))
      Dir[File.join(base_dir, "components", "**/*.rb")].each { |file| require file }
      Dir[File.join(base_dir, "game_objects", "**/*.rb")].each { |file| require file }
    end
  end
end
