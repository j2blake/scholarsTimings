module ScholarsTimings
  # What did you ask for?
  class UserInputError < StandardError
  end

  class Settings
    attr_accessor :test_plan
    attr_accessor :base_directory
    attr_accessor :results_directory
    attr_accessor :variant

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
      validate_variant()
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

    def validate_variant()
      @variant = require_value(:variant)
      (1..50).each do |index|
        path = File.expand_path("#{@variant}_#{index}", @base_directory)
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


    # ------------------------------------------------------------------------------------
    public
    # ------------------------------------------------------------------------------------

    def initialize
      @usage_text = [
        'Usage is scholars_timings \\',
        'settings_file=<settingsFile, relative to current directory> \\',
        'base_directory=<baseDirectory, defaults to current directory> \\',
        'test_plan="<name of the JMeter file>" \\',
        'variant="<name of the request and the output directory: e.g., double_drill>" \\',
      ]

      begin
        prepare_arguments_array(:settings_file, :test_plan, :base_directory, :variant)
      rescue UserInputError
        puts
        puts "ERROR: #{$!}"
        puts
        exit 1
      end
    end
  end
end