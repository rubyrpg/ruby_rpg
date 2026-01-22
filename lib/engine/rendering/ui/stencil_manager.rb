# frozen_string_literal: true

module Rendering
  module UI
    module StencilManager
      class << self
        def setup_for_rect(rect)
          chain = rect.ancestor_masks

          if chain.empty?
            disable_stencil_test
            return
          end

          # Rebuild stencil if chain changed
          if chain != @current_chain
            rebuild_stencil(chain)
            @current_chain = chain
          end

          # Configure stencil test: only draw where stencil == chain.length (intersection of all masks)
          enable_stencil_test
          Engine::GL.StencilFunc(Engine::GL::EQUAL, chain.length, 0xFF)
          Engine::GL.StencilOp(Engine::GL::KEEP, Engine::GL::KEEP, Engine::GL::KEEP)
        end

        def reset
          disable_stencil_test
          @current_chain = nil
          @stencil_enabled = false
        end

        private

        def rebuild_stencil(chain)
          # Clear stencil buffer
          Engine::GL.Clear(Engine::GL::STENCIL_BUFFER_BIT)

          enable_stencil_test

          # Draw each mask in the chain, incrementing stencil ref
          chain.each_with_index do |mask_rect, index|
            write_mask_to_stencil(mask_rect, index + 1)
          end
        end

        def write_mask_to_stencil(mask_rect, ref)
          # Disable color writes - we only want to update stencil
          Engine::GL.ColorMask(Engine::GL::FALSE, Engine::GL::FALSE, Engine::GL::FALSE, Engine::GL::FALSE)

          if ref == 1
            # First mask: write 1 everywhere it covers
            Engine::GL.StencilFunc(Engine::GL::ALWAYS, ref, 0xFF)
            Engine::GL.StencilOp(Engine::GL::KEEP, Engine::GL::KEEP, Engine::GL::REPLACE)
          else
            # Nested mask: only increment where previous masks passed (stencil == ref-1)
            Engine::GL.StencilFunc(Engine::GL::EQUAL, ref - 1, 0xFF)
            Engine::GL.StencilOp(Engine::GL::KEEP, Engine::GL::KEEP, Engine::GL::INCR)
          end

          # Draw the mask shape
          mask_rect.game_object.ui_renderers.each(&:draw)

          # Re-enable color writes
          Engine::GL.ColorMask(Engine::GL::TRUE, Engine::GL::TRUE, Engine::GL::TRUE, Engine::GL::TRUE)
        end

        def enable_stencil_test
          return if @stencil_enabled
          Engine::GL.Enable(Engine::GL::STENCIL_TEST)
          @stencil_enabled = true
        end

        def disable_stencil_test
          return unless @stencil_enabled
          Engine::GL.Disable(Engine::GL::STENCIL_TEST)
          @stencil_enabled = false
        end
      end
    end
  end
end
