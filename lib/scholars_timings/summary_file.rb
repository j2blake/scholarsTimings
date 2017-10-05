module ScholarsTimings
  class SummaryFile
    LINE_FORMAT = "%5d    %10.1f      %8.0f      %8.0f  %10.1f    %8.0f    %8.0f  %s"

    def initialize(settings)
      @summary_file = settings.summary_file
    end

    def write(stats)
      File.open(@summary_file, mode="w") do |f|
        f.puts "Count  Avg. elapsed  Min. elapsed  Max. elapsed  Avg. bytes  Min. bytes  Max. bytes  Label"
        stats.rows.each do |group|
          f.puts LINE_FORMAT %
            [group.count,
              group.average_elapsed, group.minimum_elapsed, group.maximum_elapsed,
              group.average_bytes, group.minimum_bytes, group.maximum_bytes,
              group.label]
        end
      end
      puts "SummaryFile.write"
    end
  end
end
