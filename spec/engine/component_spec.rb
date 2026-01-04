# frozen_string_literal: true

describe Engine::Component do
  describe ".create" do
    it 'creates the component' do
      expect(Engine::Component.create).to be_an(Engine::Component)
    end
  end

  describe ".set_game_object" do
    it 'sets the game object' do
      component = Engine::Component.create
      object = Engine::GameObject.create
      component.set_game_object(object)

      expect(component.game_object).to eq(object)
    end
  end

  describe "#desstroy!" do
    let(:component) { Engine::Component.create }
    let!(:game_object) { Engine::GameObject.create(components: [component]) }

    it 'destroys the component' do
      expect(component).to receive(:destroy)

      component.destroy!
      Engine::Component.erase_destroyed_components

      expect(game_object.components).to be_empty
    end

    it 'undefines the methods' do
      component.destroy!
      Engine::Component.erase_destroyed_components

      expect { component.start }.to raise_error("This Component has been destroyed but you are still trying to access start")
      expect { component.update(0) }.to raise_error("This Component has been destroyed but you are still trying to access update")
    end
  end
end
