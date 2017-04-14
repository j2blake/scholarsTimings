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

require 'rdf'
require 'rdf/turtle'

require 'model_summary/stats'

module ModelSummary
  # What did you ask for?
  class UserInputError < StandardError
  end

  class Main
    def initialize
    end

    def run
      begin
        graph = RDF::Graph.load(ARGV[0])
        puts Stats.new(graph)
      rescue UserInputError
        puts
        puts "ERROR: #{$!}"
        puts
        exit 1
      end
    end
  end
end
