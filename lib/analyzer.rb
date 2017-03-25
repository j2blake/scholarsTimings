module ScholarsTimings
  class Analyzer
    attr_accessor :stats

    def check_for_errors(raw_data)
      errors = raw_data.inject(0) do |count, row|
        count + (row[3].to_i == 200 ? 0 : 1)
      end
      raise SamplingError.new("#{errors} HTTP errors") if errors > 0
    end

    def build_stats(raw_data)
      @stats = Stats.new(@settings.sample_count)
      @stats.add_samples(raw_data)
    end

    def initialize(settings)
      @settings = settings
    end

    def analyze
      raw_data = CSV.read(@settings.jmeter_output_file).drop(1)
      check_for_errors(raw_data)
      build_stats(raw_data)
    end
  end
end
