module ScholarsTimings
  class Settings
    attr_accessor :test_plan
    attr_accessor :base_directory
    attr_accessor :results_directory
    attr_accessor :uri_file
    attr_accessor :jmeter_output_file
    attr_accessor :platform
    attr_accessor :variant
    attr_accessor :sample_count
    attr_accessor :summary_file
    attr_accessor :bottom_line_file

    # ------------------------------------------------------------------------------------
    private
    # ------------------------------------------------------------------------------------

    def prepare_arguments_array(*allowed)
      parse_arguments()
      merge_with_settings_file()
      guard_against_surprise_arguments(allowed)
      validate_args()
    end

    def parse_arguments()
      @args = {}
      ARGV.each do |arg|
        parts = arg.split('=', 2)
        if parts.size == 2
          @args[parts[0].to_sym] = parts[1]
        else
          @args[arg.to_sym] = true
        end
      end
    end

    def guard_against_surprise_arguments(allowed)
      not_allowed = @args.keys - allowed
      unless not_allowed.empty?
        user_input_error("Unexpected parameters in the command line or settings file: #{not_allowed.join(', ')}")
      end
    end

    def user_input_error(message)
      raise UserInputError.new(message + "\n" + @usage_text.join("\n                   "))
    end

    def merge_with_settings_file
      if @args[:settings_file]
        sFile = File.expand_path(@args[:settings_file])
        unless File.exist?(sFile)
          user_input_error("Settings file does not exist: #{sFile}")
        end
    #    load sFile
        @args = eval(File.open(sFile).read).merge(@args)
      end
    end

    def validate_args
      validate_base_directory()
      validate_test_plan()
      validate_uri_file()
      validate_platform()
      validate_variant()
      expand_values()
    end

    def validate_base_directory
      if @args[:base_directory]
        path = File.absolute_path(@args[:base_directory], Dir.getwd())
        user_input_error("Base directory path does not exist: '#{path}'") unless File.directory?(path)
        @base_directory = path
      else
        @base_directory = Dir.getwd()
      end
    end

    def validate_test_plan()
      path = File.absolute_path(require_value(:test_plan), @base_directory)
      user_input_error("Test plan does not exist: '#{path}'.") unless File.exist?(path)
      @test_plan = path
    end

    def validate_uri_file
      path = File.absolute_path(require_value(:uri_file), @base_directory)
      user_input_error("URI File does not exist: '#{path}'.") unless File.exist?(path)
      @uri_file = path
    end

    def validate_platform()
      @platform = require_value(:platform)
      user_input_error("Platform must be 'vivo' or 'scholars'") unless @platform == "vivo" or @platform == "scholars"
    end

    def validate_variant()
      @variant = require_value(:variant)
      (1..50).each do |index|
        path = File.expand_path("%s_%s_%d" % [@platform, @variant, index], @base_directory)
        next if File.exist?(path)
        @results_directory = path
        return
      end
      user_input_error("Already 50 outputs for '#{@variant}'")
    end

    def require_value(key)
      value = @args[key]
      user_input_error("A value for #{key} is required.") unless value
      value
    end

    def expand_values
      @jmeter_output_file = File.expand_path("output.csv", @results_directory)
      @summary_file = File.expand_path("summary.txt", @results_directory)
      @bottom_line_file = File.expand_path("bottom_line.txt", @base_directory)
      @sample_count = File.readlines(@uri_file).length
    end

    # ------------------------------------------------------------------------------------
    public
    # ------------------------------------------------------------------------------------

    def initialize
      @usage_text = [
        'Usage is scholars_timings \\',
        'settings_file=<settingsFile, relative to current directory> \\',
        'base_directory=<baseDirectory, defaults to current directory> \\',
        'uri_file=<relative to the base_directory> \\',
        'test_plan=<name of the JMeter file> \\',
        'platform=<context path of the webapp, and part of the output directory: e.g., scholars> \\',
        'variant=<name of the request and part of the output directory: e.g., double_drill> \\',
      ]

      prepare_arguments_array(:settings_file, :test_plan, :base_directory, :platform, 
          :variant, :uri_file)
    end
  end
end
