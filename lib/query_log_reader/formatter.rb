module QueryLogReader
  class Formatter
    def initialize(tree)
      @tree = tree
    end

    def to_s
      puts "BOGUS Formatter.to_s()"
      format(RawTree::ROOT_KEY, @tree, 0)
    end

    def format(key, tree, level)
      spacer = "  " * level
      buffer = spacer + format_this(key, tree)
      tree.children.to_a.sort {|kv1, kv2| kv2[1].total_elapsed <=> kv1[1].total_elapsed}.each do |kv|
        buffer += format(kv[0], kv[1], level + 1)
      end
      buffer
    end

    def format_this(key, tree)
      "%.3fs for %d quer%s => %s,    %s\n" %
      [
        tree.total_elapsed / 1000.0,
        tree.total_count,
        tree.total_count == 1 ? "y" : "ies",
        key.file_line,
        tree.records.map {|r| r.elapsed / 1000.0}.join(",  ")
      ]
    end

  end
end