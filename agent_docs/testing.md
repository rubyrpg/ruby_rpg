# Testing Guide

## Commands

```bash
# Run specific test (preferred - system tests are slow)
bundle exec rspec spec/engine/components/ui/rect_spec.rb

# Run tests in a directory
bundle exec rspec spec/engine/physics/

# Full suite (slow)
bundle exec rspec
```

## TestDriver for Frame-Based Tests

Use `TestDriver` when testing game behaviour over multiple frames:

```ruby
include TestDriver

RSpec.describe "MyFeature" do
  it "does something" do
    within_game_context(load_path: "./samples/asteroids") do
      at(0) do
        # Setup scene on first frame
        MyObject.create(Vector[100, 100])
      end
      at(1) { press(GLFW::KEY_SPACE) }
      till(5) { press(GLFW::KEY_LEFT) }  # hold key for frames 2-5
      at(10) { check_screenshot(__dir__ + "/expected.png") }
      at(15) { Engine.stop_game }
    end
  end
end
```

### TestDriver Methods

- `at(frame) { block }` - Schedule action at specific frame
- `till(frame) { block }` - Repeat action from last scheduled frame until this frame
- `press(key)` - Simulate key press (use GLFW key constants)
- `check_screenshot(path)` - Compare against expected screenshot

## Custom Matchers

Located in `spec/support/`:

- `on_screen_matcher` - Check if objects are visible
- `vector_matcher` - Vector comparisons with tolerance
- `screenshot_matcher` - Visual regression testing

## Test Cleanup

`Engine.stop_game` is called automatically after each test via `spec_helper.rb`.
