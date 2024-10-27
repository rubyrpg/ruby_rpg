# frozen_string_literal: true

module Engine
  class ObjImporter
    attr_reader :source, :destination_vertex, :destination_index

    def initialize(source, destination_vertex, destination_index)
      @source = source
      @destination_vertex = destination_vertex
      @destination_index = destination_index
    end

    def import
      obj_file = Engine::ObjFile.new(source)

      vertex_data = obj_file.vertex_data

      FileUtils.mkdir_p(File.dirname(destination_vertex)) unless File.exist?(destination_vertex)
      File.delete(destination_vertex) if File.exist?(destination_vertex)
      File.open(destination_vertex, "w") do |file|
        vertex_data.each { |d| file.puts d }
      end

      index_data = obj_file.index_data

      FileUtils.mkdir_p(File.dirname(destination_index)) unless File.exist?(destination_index)
      File.delete(destination_index) if File.exist?(destination_index)
      File.open(destination_index, "w") do |file|
        index_data.each { |i| file.puts i }
      end
    end
  end
end
