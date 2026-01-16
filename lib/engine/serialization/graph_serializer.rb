# frozen_string_literal: true

module Engine
  module Serialization
    class GraphSerializer
      class << self
        def serialize(root)
          collected = {}
          collect_refs(root, collected)
          collected.values.map { |obj| ObjectSerializer.serialize(obj) }
        end

        def deserialize(data_array)
          # Pass 1: Create all objects (with UnresolvedRefs)
          objects = data_array.map { |data| ObjectSerializer.deserialize(data) }
          registry = objects.each_with_object({}) { |obj, h| h[obj.uuid] = obj }

          # Pass 2: Resolve all references
          objects.each { |obj| resolve_references(obj, registry) }

          # Pass 3: Call awake on all objects
          objects.each(&:awake)

          objects
        end

        private

        def collect_refs(obj, collected)
          return if collected.key?(obj.uuid)

          collected[obj.uuid] = obj

          obj.class.serializable_attributes.each do |attr|
            value = obj.instance_variable_get("@#{attr}")
            collect_refs_from_value(value, collected)
          end
        end

        def collect_refs_from_value(value, collected)
          case value
          when Serializable
            collect_refs(value, collected) unless value.respond_to?(:serializable_data)
          when Array
            value.each { |v| collect_refs_from_value(v, collected) }
          when Hash
            value.each_value { |v| collect_refs_from_value(v, collected) }
          end
        end

        def resolve_references(obj, registry)
          obj.class.serializable_attributes.each do |attr|
            value = obj.instance_variable_get("@#{attr}")
            resolved = resolve_value(value, registry)
            obj.instance_variable_set("@#{attr}", resolved)
          end
        end

        def resolve_value(value, registry)
          case value
          when ObjectSerializer::UnresolvedRef
            registry[value.uuid]
          when Hash
            value.transform_values { |v| resolve_value(v, registry) }
          when Array
            value.map { |v| resolve_value(v, registry) }
          else
            value
          end
        end
      end
    end
  end
end
