module QueryLogReader
  class RawTree
    def self.build(records)
      tree = RawTree.new()
      records.each do |r|
        tree.addRecord(r, Array.new(r.trace))
      end
      tree
    end

    ROOT_KEY = LogRecord::TraceInfo.new(" (_root_:0)")
    
    attr_accessor :children
    attr_accessor :records
    attr_accessor :total_count
    attr_accessor :total_elapsed

    def initialize
      @children = Hash.new { |h, k| h[k] = RawTree.new() }
      @records = []
      @total_count = 0
      @total_elapsed = 0
    end

    def addRecord(record, trace)
      @total_count += 1
      @total_elapsed += record.elapsed
      
      if trace.empty?
        @records << record
      else
        key = trace.pop
        @children[key].addRecord(record, trace)
      end
    end

    def to_s
      format(ROOT_KEY, 0)
    end

    def format(key, level)
      spacer = "  " * level
      buffer = spacer + format_this(key)
      @children.each_pair do |k, v|
        buffer += v.format(k, level + 1)
      end
      buffer
    end

    def format_this(key)
      "%s => elapsed: %.3f, count: %d  %s   \n" %
      [key.file_line, @total_elapsed / 1000.0, @total_count, @records.map {|r| r.elapsed / 1000.0}.join(",  ")] 
    end
  end
end
