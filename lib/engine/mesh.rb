# frozen_string_literal: true

module Engine
  class Mesh
    attr_reader :vertex_data, :index_data
    private_class_method :new

    def initialize(base_path)
      @vertex_data = Mesh.load_vertex(base_path)
      @index_data = Mesh.load_index(base_path)
    end

    def self.for(mesh_file)
      base_path = File.join(GAME_DIR, "_imported", mesh_file)
      mesh_cache[base_path] ||= new(base_path)
    end

    def self.from_engine(mesh_file)
      base_path = File.join(ENGINE_DIR, "assets", "_imported", mesh_file)
      mesh_cache[base_path] ||= new(base_path)
    end

    def self.mesh_cache
      @mesh_cache ||= {}
    end

    def self.load_vertex(base_path)
      vertex_cache[base_path + ".vertex_data"]
    end

    def self.vertex_cache
      @vertex_cache ||= Hash.new do |hash, key|
        hash[key] = File.readlines(key).reject{|l| l == ""}.map(&:to_f)
      end
    end

    def self.load_index(base_path)
      index_cache[base_path + ".index_data"]
    end

    def self.index_cache
      @index_cache ||= Hash.new do |hash, key|
        hash[key] = File.readlines(key).reject{|l| l == ""}.map(&:to_i)
      end
    end

    def self.quad
      @quad ||= QuadMesh.new
    end
  end
end
