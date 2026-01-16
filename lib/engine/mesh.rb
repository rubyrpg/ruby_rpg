# frozen_string_literal: true

module Engine
  class Mesh
    include Serializable

    serialize :mesh_file, :source

    attr_reader :mesh_file, :source

    def vertex_data
      @vertex_data ||= Mesh.load_vertex(base_path)
    end

    def index_data
      @index_data ||= Mesh.load_index(base_path)
    end

    def self.for(mesh_file)
      base_path = File.join(GAME_DIR, "_imported", mesh_file)
      mesh_cache[base_path] ||= create(mesh_file: mesh_file, source: :game)
    end

    def self.from_engine(mesh_file)
      base_path = File.join(ENGINE_DIR, "assets", "_imported", mesh_file)
      mesh_cache[base_path] ||= create(mesh_file: mesh_file, source: :engine)
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

    private

    def base_path
      @base_path ||= if @source == :engine
        File.join(ENGINE_DIR, "assets", "_imported", @mesh_file)
      else
        File.join(GAME_DIR, "_imported", @mesh_file)
      end
    end
  end
end
