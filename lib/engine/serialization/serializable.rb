# frozen_string_literal: true

require 'securerandom'

module Engine
  module Serializable
    class InitializeNotAllowedError < StandardError; end

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

    def self.register_class(klass)
      @allowed_classes[klass.name] = klass if klass.name
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

    def uuid
      @uuid ||= SecureRandom.uuid
    end
  end
end
