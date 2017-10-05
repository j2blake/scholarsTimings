=begin
Run                   Samples  Passes  Avg. elapsed  Bytes per pass Test Plan / URI file
person_word_count_02       10      10         301.5         114,940 PersonWordClouds.jmx / PersonUris.csv
double_drill_10            10      10       12994.0       2,603,032
=end
module ScholarsTimings
  class BottomLineFile
    LINE_FORMAT = ""
    def read_existing_file
      if File.exist?(@settings.bottom_line_file)
        raw_lines = File.readlines(@settings.bottom_line_file)
        @lines = raw_lines.drop(1).map {|l| l.strip.split(' ', 6)}
      else
        @lines = []
      end
    end

    def add_row
      @lines << [
        File.basename(@settings.results_directory),
        @stats.rows.length,
        @stats.rows[0].count,
        average(@stats.rows.map {|r| r.average_elapsed}),
        @stats.rows.map {|r| r.average_bytes}.inject(:+),
        "#{File.basename(@settings.test_plan)} / #{File.basename(@settings.uri_file)}"
      ]
    end

    def sort
      @lines.sort! {|a, b| a[0] <=> b[0]}
    end

    def write_new_file
      File.open(@settings.bottom_line_file, "w") do |f|
#        run_width = @lines.map {|l| puts "LINE: >> #{l.join(" ~ ")} <<"; 3}.max { |a, b| a > b }
        run_width = @lines.map {|l| l[0].size}.max
        run_title = "Run".ljust(run_width, " ")
        f.puts "#{run_title}  Samples  Passes  Avg. elapsed  Bytes per pass Test Plan / URI file"
        @lines.each do |line|
          f.puts "%-#{run_width}s  %7d  %6d  %12.1f  %14d %s" % line
        end
      end
    end

    def average(arr)
      arr.inject(0.0) { |sum, el| sum + el } / arr.size
    end


    def initialize(settings)
      @settings = settings
    end
    def write(stats)
      @stats = stats
      read_existing_file
      add_row
      sort
      write_new_file
    end
  end
end
