# frozen_string_literal: true

module Engine
  module StandardObjects
    def self.default_material
      @default_material ||= begin
        mat = Engine::Material.new(Engine::Shader.default)
        mat.set_vec3("baseColour", Vector[1.0, 1.0, 1.0])
        mat.set_texture("image", nil)
        mat.set_texture("normalMap", nil)
        mat.set_float("diffuseStrength", 0.5)
        mat.set_float("specularStrength", 0.5)
        mat.set_float("specularPower", 32.0)
        mat.set_vec3("ambientLight", Vector[0.02, 0.02, 0.02])
        mat.set_float("roughness", 0.5)
        mat
      end
    end
  end
end
