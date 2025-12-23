# frozen_string_literal: true

module ShrinkRacer
  module RoadTile
    def self.create(tile_number, pos, rotation)
      parent = Engine::GameObject.new(
        "Road Tile",
        pos: pos,
        rotation: rotation,
        scale: Vector[1, 1, 1],
      )

      Engine::GameObject.new(
        "Road Tile",
        pos: Vector[-1.5, 0, 1.5],
        rotation: Vector[0, 0, 0],
        scale: Vector[1, 1, 1],
        components: [
          Engine::Components::MeshRenderer.new(Engine::Mesh.for(
            "assets/road_tiles/roadTile_" + tile_number),
                                               material, static: true
          ),
        ],
        parent: parent
      )
      parent
    end

    def self.create_straight_road(pos, rotation)
      road = create("162", pos, rotation)
      dice = rand
      if dice < 0.3
        local_pos = Vector[rand(-1.0..1.0), 0.575, rand(-0.8..0.8)]
        cone_pos = road.local_to_world_coordinate(local_pos)
        Props.create_cone(cone_pos, rotation)
      elsif dice < 0.6
        local_pos = Vector[rand(-1.0..1.0), 0.575, rand(-0.8..0.8)]
        cone_pos = road.local_to_world_coordinate(local_pos)
        Props.create_coin(cone_pos, rotation)
      end
      road
    end

    def self.create_corner_road(pos, rotation)
      create("153", pos, rotation + Vector[0, 270, 0])
    end

    def self.create_t_junction_road(pos, rotation)
      create("150", pos, rotation + Vector[0, 180, 0])
    end

    def self.create_cross_road(pos, rotation)
      create("141", pos, rotation)
    end

    def self.create_bridge_road(pos, rotation)
      create("188", pos, rotation + Vector[0, 90, 0])
    end

    def self.create_pond(pos, rotation)
      create("001", pos, rotation)
    end

    def self.create_grass(pos, rotation)
      1.times do
        place_tree(pos + Vector[rand(-1.5..1.5), 0.5, rand(-1.5..1.5)], rotation)
      end
      create("163", pos, rotation)
    end

    def self.place_tree(pos, rotation)
      file_number = ["019", "020"].sample
      offsets = {
        "019" => Vector[-0.4, 0, 0.5],
        "020" => Vector[-0.85, 0, 0.75]
      }
      scale = rand(0.5..1.0)
      parent = Engine::GameObject.new(
        "Tree",
        pos: pos,
        rotation: rotation,
        scale: Vector[scale, scale, scale],
        components: [
          TreeCollider.new(0.2 * scale),
        ]
      )
      Engine::GameObject.new(
        "Tree",
        pos: offsets[file_number],
        rotation: rotation,
        scale: Vector[1, 1, 1],
        components: [
          Engine::Components::MeshRenderer.new(Engine::Mesh.for(
            "assets/road_tiles/roadTile_" + file_number),
                                               material,
                                               static: true
          ),
        ],
        parent: parent
      )
      parent
    end

    private

    def self.material
      @material ||=
        begin
          material = Engine::Material.new(Engine::Shader.vertex_lit)
          material.set_texture("image", nil)
          material.set_texture("normalMap", nil)
          material.set_float("diffuseStrength", 0.5)
          material.set_float("specularStrength", 0.7)
          material.set_float("specularPower", 32.0)
          material.set_vec3("ambientLight", Vector[0.12, 0.1, 0.18])
          material
        end
    end

    def self.tree_material
      @tree_material ||=
        begin
          material = Engine::Material.new(Engine::Shader.vertex_lit)
          material.set_texture("image", nil)
          material.set_texture("normalMap", nil)
          material.set_float("diffuseStrength", 0.8)
          material.set_float("specularStrength", 5.0)
          material.set_float("specularPower", 32.0)
          material.set_vec3("ambientLight", Vector[0.15, 0.12, 0.2])
          material
        end
    end
  end
end
