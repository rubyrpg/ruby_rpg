# frozen_string_literal: true

describe Engine::Components::SpriteRenderer do
  let(:mock_material) do
    material = Engine::Material.allocate
    material.instance_variable_set(:@uuid, "test-material-uuid")
    material
  end

  describe ".create" do
    it "creates a sprite renderer with provided material" do
      renderer = Engine::Components::SpriteRenderer.create(material: mock_material)

      expect(renderer.material).to eq(mock_material)
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Components::SpriteRenderer.create(material: mock_material)

      serialized = original.to_serialized

      expect(serialized[:material][:_ref]).to eq("test-material-uuid")

      restored = Engine::Serializable.from_serialized(serialized)
      restored.awake

      # Without deserialize_all, refs remain unresolved
      expect(restored.material).to be_a(Engine::Serializable::UnresolvedRef)
      expect(restored.material.uuid).to eq("test-material-uuid")
    end
  end
end
