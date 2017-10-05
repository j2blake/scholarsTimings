=begin
--------------------------------------------------------------------------------

Accept setttings from file (if provided) and merge from command line.
Complain if any of the setttings are missing
Complain if required files are not present
If directories or files already exist, ask before overwriting them.

Modify the jmeter file (specified in the settings)
The query URL gets the variant (settings) appended to it: /department_word_cloud_double?department=foobar.
The results are stored in base_directory (settings)/batch (settings)/variant_iteration
  for exmple ~/Development/Scholars//visualizations/Performance/DepartmentWordCloud/small_model/double_2017-03-20_12-15-00
  if the directory already exists, fail
  else, create it.

Run JMeter in command-line mode
  http://meter.apache.org/usermanual/get-started.html#non_gui

Process the output file(s) into a summary
  compare the sizes to find the interval (no, from setting).
  produce times, and bytes for each request
  produce one-line summary file (average time, average size overall)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
=end

$: << File.dirname(File.expand_path(__FILE__))
require 'csv'

require 'scholars_timings/settings'
require 'scholars_timings/analyzer'
require 'scholars_timings/stats'
require 'scholars_timings/summary_file'
require 'scholars_timings/bottom_line_file'

module ScholarsTimings
  # What did you ask for?
  class UserInputError < StandardError
  end

  # HTTP errors in the samples
  class SamplingError < StandardError
  end

  class Main
    def run_jmeter
      Dir.mkdir(@settings.results_directory)
      args = []
      args << '-n'
      args << '-t' << @settings.test_plan
      args << '-j' << File.expand_path("jmeter.log", @settings.results_directory)
      args << '-l' << @settings.jmeter_output_file
      args << "-Jdir.base=#{@settings.base_directory}"
      args << "-Jdir.output=#{@settings.results_directory}"
      args << "-Jcontext.path=#{@settings.platform}"
      args << "-Jaction.name=#{@settings.variant}"
      args << "-Jfile.uris=#{@settings.uri_file}"
      args << "-Jsample_variables=LABEL"
      success = system("jmeter", *args)
      raise "Jmeter failed" unless success
      puts
    end

    def analyze_results
      analyzer = Analyzer.new(@settings)
      analyzer.analyze
      @stats = analyzer.stats
      SummaryFile.new(@settings).write(@stats)
      BottomLineFile.new(@settings).write(@stats)
    end

    def initialize
      begin
        @settings = Settings.new
      rescue UserInputError
        puts
        puts "ERROR: #{$!}"
        puts
        exit 1
      end
    end

    def run
      begin
        run_jmeter()
        analyze_results()
      rescue SamplingError
        puts
        puts "ERROR: #{$!}"
        puts
        exit 1
      end
    end
  end
end
