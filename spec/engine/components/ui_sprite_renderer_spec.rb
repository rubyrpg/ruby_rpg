# frozen_string_literal: true

describe Engine::Components::UISpriteRenderer do
  let(:mock_material) do
    material = Engine::Material.allocate
    material.instance_variable_set(:@uuid, "test-material-uuid")
    material
  end

  describe ".create" do
    it "creates a ui sprite renderer with material" do
      renderer = Engine::Components::UISpriteRenderer.create(
        material: mock_material
      )

      expect(renderer.material).to eq(mock_material)
    end
  end

  describe "serialization round-trip" do
    it "serializes and deserializes correctly" do
      original = Engine::Components::UISpriteRenderer.create(
        material: mock_material
      )

      serialized = Engine::Serialization::ObjectSerializer.serialize(original)

      expect(serialized[:material][:_ref]).to eq("test-material-uuid")
    end
  end
end
