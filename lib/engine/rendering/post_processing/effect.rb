# frozen_string_literal: true

module Rendering
  module Effect
    attr_accessor :enabled

    def enabled
      @enabled.nil? ? true : @enabled
    end
  end
end
