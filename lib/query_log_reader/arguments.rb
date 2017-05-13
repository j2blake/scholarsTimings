=begin
  For now, fake it. The file is ./scholars.all.log and the times are 
  all-inclusive.
=end

module QueryLogReader
  class Arguments
    attr_accessor :startDate
    attr_accessor :endDate
    attr_accessor :filePath
    
    def initialize(args)
      puts "BOGUS Arguments.initialize()"
      @startDate = DateTime.parse("2017-01-11T11:46:40")
      @endDate = DateTime.new(2021, 1, 1, 1, 1, 1)
      @filePath = File.expand_path("./scholars.all.log")
    end
  end
end