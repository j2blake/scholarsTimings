module ScholarsTimings
  class Stats
    class StatsRow
      attr_accessor :count
      attr_accessor :average_elapsed
      attr_accessor :maximum_elapsed
      attr_accessor :minimum_elapsed
      attr_accessor :average_bytes
      attr_accessor :maximum_bytes
      attr_accessor :minimum_bytes
      attr_accessor :label

      def initialize
        @elapsed_times = []
        @bytes = []
        summarize
      end

      def add_to_row(sample)
        @elapsed_times << sample[1].to_i
        @bytes << sample[9].to_i
        @label = sample[16]
        summarize
      end

      def summarize
        @count = @elapsed_times.length
        @average_elapsed = average(@elapsed_times)
        @minimum_elapsed = @elapsed_times.min || 0
        @maximum_elapsed = @elapsed_times.max || 0
        @average_bytes = average(@bytes)
        @minimum_bytes = @bytes.min
        @maximum_bytes = @bytes.max
      end

      def average(arr)
        arr.inject(0.0) { |sum, el| sum + el } / arr.size
      end
    end

    attr_accessor :rows

    def initialize(sample_count)
      @rows = Array.new(sample_count) { StatsRow.new }
    end

    def add_samples(samples)
      samples.each_index do |index|
        which_row = index % @rows.length
        @rows[which_row].add_to_row(samples[index])
      end
    end

    def to_s
      @rows.join("\n")
    end
  end
end
