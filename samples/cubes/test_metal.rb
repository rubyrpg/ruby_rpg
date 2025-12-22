#!/usr/bin/env ruby
# Simple test script to verify Metal compute shader works

require 'fiddle'
require 'fiddle/import'

# Set up GAME_DIR for the compute shader path
GAME_DIR = File.dirname(__FILE__)

require_relative '../../lib/engine/metal/metal_bindings'
require_relative '../../lib/engine/metal/device'
require_relative '../../lib/engine/metal/compute_shader'

puts "=== Testing Metal Compute Shader ==="

begin
  puts "\n1. Creating Metal device..."
  device = Engine::Metal::Device.instance
  puts "   ✓ Device created: #{device.device.inspect}"
  puts "   ✓ Command queue: #{device.command_queue.inspect}"

  puts "\n2. Loading compute shader..."
  shader = Engine::Metal::ComputeShader.new("assets/hello_cubes.metal")
  puts "   ✓ Shader compiled successfully"

  puts "\n3. Creating a simple Metal texture for testing..."
  # Create a simple texture descriptor
  descriptor = Engine::Metal::ObjC.msg(Engine::Metal::ObjC.cls('MTLTextureDescriptor'), 'new')
  Engine::Metal::ObjC.msg(descriptor, 'setPixelFormat:', 125)  # RGBA32Float
  Engine::Metal::ObjC.msg(descriptor, 'setWidth:', 64)
  Engine::Metal::ObjC.msg(descriptor, 'setHeight:', 64)
  Engine::Metal::ObjC.msg(descriptor, 'setUsage:', 3)  # Read | Write
  Engine::Metal::ObjC.msg(descriptor, 'setStorageMode:', 0)  # Shared

  test_texture = Engine::Metal::ObjC.msg(device.device, 'newTextureWithDescriptor:', descriptor)
  puts "   ✓ Test texture created: #{test_texture.inspect}"

  puts "\n4. Dispatching compute shader..."
  shader.dispatch(64, 64, 1, textures: [test_texture, test_texture], floats: { "u_time" => 0.5 })
  puts "   ✓ Dispatch completed without error!"

  puts "\n=== All Metal tests passed! ==="

rescue => e
  puts "\n✗ Error: #{e.message}"
  puts e.backtrace.first(10).join("\n")
  exit 1
end
