# frozen_string_literal: true

describe Engine::Components::MeshRenderer do
  let(:mock_mesh) { double("mesh") }
  let(:mock_material) do
    material = Engine::Material.allocate
    material.instance_variable_set(:@uuid, "test-material-uuid")
    material
  end

  describe ".create" do
    it "creates a mesh renderer with provided values" do
      renderer = Engine::Components::MeshRenderer.create(
        mesh: mock_mesh,
        material: mock_material,
        static: true
      )

      expect(renderer.mesh).to eq(mock_mesh)
      expect(renderer.material).to eq(mock_material)
      expect(renderer.static).to eq(true)
    end

    it "defaults static to false" do
      renderer = Engine::Components::MeshRenderer.create(
        mesh: mock_mesh,
        material: mock_material
      )

      expect(renderer.static).to eq(false)
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Components::MeshRenderer.create(
        mesh: mock_mesh,
        material: mock_material,
        static: true
      )

      serialized = original.to_serialized

      expect(serialized[:static]).to eq({ _class: "TrueClass", value: true })
      expect(serialized[:material][:_ref]).to eq("test-material-uuid")
    end
  end
end
