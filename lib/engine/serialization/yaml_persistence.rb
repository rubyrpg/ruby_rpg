# frozen_string_literal: true

require 'yaml'

module Engine
  module Serialization
    class YamlPersistence
      class << self
        def save(obj, path)
          data = GraphSerializer.serialize(obj)
          File.write(path, data.to_yaml)
        end

        def load(path)
          data = YAML.load_file(path, permitted_classes: [Symbol])
          data_array = data.is_a?(Array) ? data : [data]
          GraphSerializer.deserialize(data_array).first
        end

        def load_all(paths)
          data_array = paths.flat_map do |path|
            data = YAML.load_file(path, permitted_classes: [Symbol])
            data.is_a?(Array) ? data : [data]
          end
          GraphSerializer.deserialize(data_array)
        end
      end
    end
  end
end
