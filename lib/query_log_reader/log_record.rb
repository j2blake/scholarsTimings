=begin

parseRecords(arguments) will read the log file, break it up into buffers,
   and return an array of records made from those buffers.

initialize(buffer) creates the record
  Time stamp - a DateTime
  elapsed time - number of milliseconds
  query string
  query type - actually the RDFService method name
  response type - blank or an output format (JSON, NTRIPLES, etc.)
  stack trace - array of TraceElements with the class/method info and the file/line info
=end

module QueryLogReader
  TIME_STAMP_PARSER = '%Y-%m-%d %H:%M:%S'

  FIRST_LINE_SCANNER = /
    ^            #
    (.{19})      # time stamp
    .+\]\s+      #
    ([\d.]+)     # elapsed time
    \s+          #
    (\w+)        # query type
    \s+\[        #
    (.+)         # query
    \]\s*        #
    (.*)         # trace info
    $            #
  /x

  TRACE_INFO_SCANNER = /
    ^\s*         #
    (.+)         # class and method
    \(           #
    (.+)         # filename and line
    \)\s*$       #
  /x
  #
  class LogRecord
    def self.parseRecords(arguments)
      records = []
      accumulating = false
      buffer = []

      File.foreach(arguments.filePath) do |line|
        if accumulating
          if isEndLine(line)
            accumulating = false
            records << LogRecord.new(buffer)
            buffer = []
          else
            buffer << line
          end
        else
          if isStartLine(line) && isWithinInterval(arguments, line)
            accumulating = true
            buffer << line
          else
            # Throw it away
          end
        end
      end
      if accumulating
        records << LogRecord.new(buffer)
      end
      records
    end

    def self.isEndLine(line)
      line.strip.empty? || line.strip == "..."
    end

    def self.isStartLine(line)
      return line.index("[RDFServiceLogger]")
    end

    def self.isWithinInterval(arguments, line)
      stamp = DateTime.strptime(line[0..18], TIME_STAMP_PARSER)
      stamp >= arguments.startDate && stamp <= arguments.endDate
    end

    class TraceInfo
      attr_accessor :class_method
      attr_accessor :file_line
      def initialize(infoString)
        @class_method, @file_line = infoString.scan(TRACE_INFO_SCANNER).flatten
      end

      def ==(o)
        o.class == self.class && o.state == state
      end

      protected

      def state
        [@class_method, @file_line]
      end

      alias_method :eql?, :==

      def hash
        state.hash
      end

      def to_s
        "TraceInfo[#{@class_method} #{@file_line}]"
      end
    end

    attr_accessor :stamp
    attr_accessor :elapsed
    attr_accessor :query
    attr_accessor :query_type
    attr_accessor :response_type
    attr_accessor :trace

    def initialize(buffer)
      stamp_string, elapsed_string, @query_type, query_string, trace_info_string = buffer.shift.scan(FIRST_LINE_SCANNER).flatten
      @stamp = DateTime.strptime(stamp_string, TIME_STAMP_PARSER)
      @elapsed = (elapsed_string.to_f * 1000).to_i
      @query, @response_type = parse_query(query_string)
      @trace = [TraceInfo.new(trace_info_string)] + buffer.map {|l| TraceInfo.new(l)}
    end

    def parse_query(q_string)
      response_type, query = q_string.scan(/(\w+),\s(.+)/).flatten
      if query
        [query, response_type]
      else
        [q_string, ""]
      end
    end

    def to_s
      "LogRecord[\n  stamp=%s,\n  elapsed=%s,\n  query=%s,\n  query_type=%s,\n  response_type=%s,\n  trace=%s\n]" %
      [@stamp, @elapsed, @query, @query_type, @response_type, @trace.join(",\n        ")]
    end
  end
end