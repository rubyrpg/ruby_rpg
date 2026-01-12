# frozen_string_literal: true

require 'securerandom'
require 'yaml'

module Engine
  module Serializable
    class UnauthorizedClassError < StandardError; end
    class InitializeNotAllowedError < StandardError; end

    # Placeholder for unresolved references during first pass
    UnresolvedRef = Struct.new(:uuid, :class_name)

    @allowed_classes = {}

    def self.included(base)
      base.extend(ClassMethods)
      @allowed_classes[base.name] = base if base.name

      # Prevent subclasses from defining initialize
      base.define_singleton_method(:method_added) do |method_name|
        if method_name == :initialize
          raise InitializeNotAllowedError,
            "#{self.name} cannot define 'initialize'. " \
            "Serializable classes must use 'awake' for initialization logic and be created with '.create'"
        end
        super(method_name) if defined?(super)
      end
    end

    # Default awake implementation - override in subclasses
    def awake
    end

    def self.allowed_class?(class_name)
      @allowed_classes.key?(class_name)
    end

    def self.get_class(class_name)
      @allowed_classes[class_name]
    end

    def self.deserialize_all(data_array)
      # Pass 1: Create all objects, leave references as placeholders
      objects = data_array.map { |data| from_serialized(data) }
      registry = objects.each_with_object({}) { |obj, h| h[obj.uuid] = obj }

      # Pass 2: Resolve all references
      objects.each { |obj| resolve_references(obj, registry) }

      # Pass 3: Call awake on all objects after references resolved
      objects.each(&:awake)

      objects
    end

    def self.from_serialized(data)
      class_name = data[:_class]
      raise UnauthorizedClassError, "Class '#{class_name}' is not allowed" unless allowed_class?(class_name)

      klass = get_class(class_name)
      instance = klass.allocate
      instance.instance_variable_set(:@uuid, data[:uuid])

      klass.serializable_attributes.each do |attr|
        value = deserialize_value(data[attr])
        instance.instance_variable_set("@#{attr}", value)
      end

      instance
    end

    def self.deserialize_value(data)
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
      elsif allowed_class?(class_name)
        klass = get_class(class_name)
        if klass.respond_to?(:from_serializable_data)
          klass.from_serializable_data(data)
        else
          from_serialized(data)
        end
      else
        raise UnauthorizedClassError, "Class '#{class_name}' is not allowed"
      end
    end

    def self.resolve_references(obj, registry)
      klass = obj.class
      klass.serializable_attributes.each do |attr|
        value = obj.instance_variable_get("@#{attr}")
        resolved = resolve_value(value, registry)
        obj.instance_variable_set("@#{attr}", resolved)
      end
    end

    def self.resolve_value(value, registry)
      case value
      when UnresolvedRef
        registry[value.uuid]
      when Hash
        value.transform_values { |v| resolve_value(v, registry) }
      when Array
        value.map { |v| resolve_value(v, registry) }
      else
        value
      end
    end

    module ClassMethods
      def inherited(subclass)
        super
        Serializable.register_class(subclass)
      end

      def serialize(*attributes)
        @own_serializable_attributes ||= []
        @own_serializable_attributes.concat(attributes)
      end

      def serializable_attributes
        parent_attrs = if superclass.respond_to?(:serializable_attributes)
                         superclass.serializable_attributes
                       else
                         []
                       end
        own_attrs = @own_serializable_attributes || []
        parent_attrs + own_attrs
      end

      def create(**attrs)
        instance = allocate
        instance.instance_variable_set(:@uuid, SecureRandom.uuid)
        attrs.each do |attr, value|
          instance.instance_variable_set("@#{attr}", value)
        end
        instance.awake
        instance
      end
    end

    def self.register_class(klass)
      @allowed_classes[klass.name] = klass if klass.name
    end

    def self.from_file(path)
      data = YAML.load_file(path, permitted_classes: [Symbol])
      instance = from_serialized(data)
      instance.awake
      instance
    end

    def self.from_files(paths)
      data_array = paths.map { |path| YAML.load_file(path, permitted_classes: [Symbol]) }
      deserialize_all(data_array)
    end

    def uuid
      @uuid ||= SecureRandom.uuid
    end

    def to_serialized
      result = {
        _class: self.class.name,
        uuid: uuid
      }

      self.class.serializable_attributes.each do |attr|
        value = instance_variable_get("@#{attr}")
        result[attr] = serialize_value(value)
      end

      result
    end

    def to_file(path)
      File.write(path, to_serialized.to_yaml)
    end

    private

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
  end
end
