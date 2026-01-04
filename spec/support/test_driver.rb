module TestDriver
  class TestDriverComponent < Engine::Component
    include RSpec::Matchers
    include RSpec::Mocks

    def initialize(&block)
      @instructions = block
      @timed_instructions = {}
      instance_eval(&block)
    end

    def update(delta_time)
      if @timed_instructions[current_tick]
        @timed_instructions[current_tick].call
      end
      set_tick(current_tick + 1)
    end

    def at(tick, &block)
      @timed_instructions[tick] = block
    end

    def till(tick, &block)
      max_tick = @timed_instructions.keys.max || 0
      ((max_tick + 1)..tick).each do |frame|
        @timed_instructions[frame] = block
      end
    end

    def press(key)
      Engine::Input.instance_variable_get(:@keys)[key] = :down
    end

    def check_screenshot(file)
      Engine::Screenshoter.screenshot do |screenshot|
        expect(screenshot).to match_screenshot_on_disk(file)
      end
    end
  end

  def set_tick(tick)
    $current_tick = tick
  end

  def current_tick
    $current_tick ||= 0
  end

  def within_game_context(frame_duration: 0.1, load_path: nil, &block)
    set_tick(0)
    allow(Time).to(receive(:now)) { current_tick * frame_duration }
    Engine::AutoLoader.load(load_path)
    if !Engine.engine_started?
      Engine.open_window
    end
    Engine.main_game_loop do
      Engine::GameObject.create(name: "Test Driver", components: [TestDriverComponent.new(&block)])
    end
  end
end
