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
require 'settings'

module ScholarsTimings

  class Main
    def initialize
      @settings = Settings.new
      puts "Main.new"
    end

    def run
      Dir.mkdir(@settings.results_directory)
      args = []
      args << '-n'
      args << '-t' << @settings.test_plan
      args << '-j' << File.expand_path("jmeter.log", @settings.results_directory)
      args << '-l' << File.expand_path("sample.jtl", @settings.results_directory)
      args << "-Jdir.base=#{@settings.base_directory}"
      args << "-Jdir.output=#{@settings.results_directory}"
      args << "-Jaction.name=#{@settings.variant}"
      system("jmeter", *args)
      puts "Main.run2"
    end
  end
end
