# Welcome to ruby_rpg!

`ruby_rpg` is an OpenGL based game engine written in Ruby.
It is designed to be easy to use and easy to extend. 
It is still in the early stages of development, but it is already capable of rendering both 2D and 3D graphics.

## Installation
You can find full instructions on th [wiki](https://github.com/rubyrpg/ruby_rpg/wiki/Installation).

## Usage
You can find docs and guides on the [wiki](https://github.com/rubyrpg/ruby_rpg/wiki).
For a basic example to get you up off the ground take a look at [hello_ruby_rpg](https://github.com/rubyrpg/hello_ruby_rpg).
For some more complex examples you can take a look in the samples folder of this repo.

## Development Setup
If you're working on the engine itself, you'll need to compile the native extensions:

```bash
bundle install
bundle exec rake compile
```

Then you can run the samples:
```bash
bundle exec ruby samples/cubes/cubes.rb
```

## Testing
```bash
bundle exec rspec                    # run all tests
bundle exec rspec --tag '~system'    # skip system tests (faster)
bundle exec rspec spec/path/to_spec.rb  # run specific test
```

System tests launch the engine and render frames, so they're slower. Use `--tag ~system` for quicker feedback during development.

## Contributing
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
6. I'll get to reviewing it as soon as I can!
