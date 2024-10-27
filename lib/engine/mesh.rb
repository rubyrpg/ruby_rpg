# frozen_string_literal: true

module Engine
  class Mesh
    attr_reader :vertex_data, :index_data
    private_class_method :new

    def initialize(mesh_file)
      @vertex_data = Mesh.open_vertex(mesh_file)
      @index_data = Mesh.open_index(mesh_file)
    end

    def self.for(mesh_file)
      mesh_cache[mesh_file]
    end

    def self.mesh_cache
      @mesh_cache ||= Hash.new do |hash, key|
        hash[key] = new(key)
      end
    end

    def self.open_vertex(mesh_file)
      vertex_cache[File.join(ROOT, "_imported", mesh_file + ".vertex_data")]
    end

    def self.vertex_cache
      @index_data_cache ||= Hash.new do |hash, key|
        hash[key] = File.readlines(key).reject{|l| l == ""}.map(&:to_f)
      end
    end

    def self.open_index(mesh_file)
      index_cache[File.join(ROOT, "_imported", mesh_file + ".index_data")]
    end

    def self.index_cache
      @index_data_cache ||= Hash.new do |hash, key|
        hash[key] = File.readlines(key).reject{|l| l == ""}.map(&:to_i)
      end
    end
  end
end
