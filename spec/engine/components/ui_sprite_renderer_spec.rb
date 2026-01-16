# frozen_string_literal: true

describe Engine::Components::UISpriteRenderer do
  let(:mock_material) do
    material = Engine::Material.allocate
    material.instance_variable_set(:@uuid, "test-material-uuid")
    material
  end

  describe ".create" do
    it "creates a ui sprite renderer with corner positions and material" do
      renderer = Engine::Components::UISpriteRenderer.create(
        v1: Vector[0, 0],
        v2: Vector[100, 0],
        v3: Vector[100, 100],
        v4: Vector[0, 100],
        material: mock_material
      )

      expect(renderer.v1).to eq(Vector[0, 0])
      expect(renderer.v2).to eq(Vector[100, 0])
      expect(renderer.v3).to eq(Vector[100, 100])
      expect(renderer.v4).to eq(Vector[0, 100])
      expect(renderer.material).to eq(mock_material)
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Components::UISpriteRenderer.create(
        v1: Vector[0, 0],
        v2: Vector[100, 0],
        v3: Vector[100, 100],
        v4: Vector[0, 100],
        material: mock_material
      )

      serialized = Engine::Serialization::ObjectSerializer.serialize(original)

      expect(serialized[:v1]).to eq({ _class: "Vector", value: [0, 0] })
      expect(serialized[:material][:_ref]).to eq("test-material-uuid")
    end
  end
end
