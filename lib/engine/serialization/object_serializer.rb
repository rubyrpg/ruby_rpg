# frozen_string_literal: true

module Engine
  module Serialization
    class ObjectSerializer
      class UnauthorizedClassError < StandardError; end

      UnresolvedRef = Struct.new(:uuid, :class_name)

      class << self
        def serialize(obj)
          result = {
            _class: obj.class.name,
            uuid: obj.uuid
          }

          obj.class.serializable_attributes.each do |attr|
            value = obj.instance_variable_get("@#{attr}")
            result[attr] = serialize_value(value)
          end

          result
        end

        def deserialize(data)
          class_name = data[:_class]
          raise UnauthorizedClassError, "Class '#{class_name}' is not allowed" unless Serializable.allowed_class?(class_name)

          klass = Serializable.get_class(class_name)
          instance = klass.allocate
          instance.instance_variable_set(:@uuid, data[:uuid])

          klass.serializable_attributes.each do |attr|
            value = deserialize_value(data[attr])
            instance.instance_variable_set("@#{attr}", value)
          end

          instance
        end

        def serialize_value(value)
          if value.is_a?(Serializable) && value.respond_to?(:serializable_data)
            { _class: value.class.name, **value.serializable_data }
          elsif value.is_a?(Serializable) && value.respond_to?(:uuid)
            { _class: value.class.name, _ref: value.uuid }
          elsif value.is_a?(Hash)
            { _class: "Hash", value: value.transform_values { |v| serialize_value(v) } }
          elsif value.is_a?(Array)
            { _class: "Array", value: value.map { |v| serialize_value(v) } }
          elsif value.is_a?(Symbol)
            { _class: "Symbol", value: value.to_s }
          elsif value.is_a?(Vector)
            { _class: "Vector", value: value.to_a }
          elsif value.is_a?(Matrix)
            { _class: "Matrix", value: value.to_a }
          elsif value.is_a?(Engine::Quaternion)
            { _class: "Engine::Quaternion", value: [value.w, value.x, value.y, value.z] }
          else
            { _class: value.class.name, value: value }
          end
        end

        def deserialize_value(data)
          return nil if data.nil?

          class_name = data[:_class]

          if data.key?(:_ref)
            UnresolvedRef.new(data[:_ref], class_name)
          elsif %w[String Integer Float TrueClass FalseClass NilClass].include?(class_name)
            data[:value]
          elsif class_name == "Symbol"
            data[:value].to_sym
          elsif class_name == "Vector"
            Vector[*data[:value]]
          elsif class_name == "Matrix"
            Matrix[*data[:value]]
          elsif class_name == "Engine::Quaternion"
            Engine::Quaternion.new(*data[:value])
          elsif class_name == "Hash"
            data[:value].transform_values { |v| deserialize_value(v) }
          elsif class_name == "Array"
            data[:value].map { |v| deserialize_value(v) }
          elsif Serializable.allowed_class?(class_name)
            klass = Serializable.get_class(class_name)
            if klass.respond_to?(:from_serializable_data)
              klass.from_serializable_data(data)
            else
              deserialize(data)
            end
          else
            raise UnauthorizedClassError, "Class '#{class_name}' is not allowed"
          end
        end
      end
    end
  end
end
