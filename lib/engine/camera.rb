# frozen_string_literal: true

module Engine
  class Camera
    def self.instance
      @instance
    end

    def self.instance=(new_instance)
      @instance = new_instance
    end
  end
end