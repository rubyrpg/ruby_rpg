# frozen_string_literal: true

module Rendering
  class GpuTimer
    class << self
      def enabled?
        @enabled ||= false
      end

      def enable
        @enabled = true
        @frame_count = 0
        @stages = []
        @queries = {}
        puts "GPU Profiler: ON"
      end

      def measure(stage)
        unless enabled?
          return yield
        end

        query_id = query_for(stage)
        GL.BeginQuery(GL::TIME_ELAPSED, query_id)
        result = yield
        GL.EndQuery(GL::TIME_ELAPSED)
        result
      end

      def print_results
        return unless enabled?

        @frame_count += 1
        return unless (@frame_count % 60) == 0

        results = {}
        @stages.each do |stage|
          buf = ' ' * 8
          GL.GetQueryObjectui64v(@queries[stage], GL::QUERY_RESULT, buf)
          results[stage] = buf.unpack1('Q') / 1_000_000.0
        end

        total = results.values.sum
        puts "\n=== GPU Timing ==="
        @stages.each do |stage|
          ms = results[stage]
          pct = total > 0 ? (ms / total * 100).round(1) : 0
          bar = "█" * (pct / 5).to_i
          puts format("%-20s %6.2f ms (%5.1f%%) %s", stage, ms, pct, bar)
        end
        puts format("%-20s %6.2f ms", "TOTAL", total)
        puts "===================="
      end

      private

      def query_for(stage)
        return @queries[stage] if @queries[stage]

        buf = ' ' * 4
        GL.GenQueries(1, buf)
        @queries[stage] = buf.unpack1('L')
        @stages << stage
        @queries[stage]
      end
    end
  end
end
