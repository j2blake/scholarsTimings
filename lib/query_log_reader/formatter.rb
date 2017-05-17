module QueryLogReader
  class Formatter
    def initialize(tree)
      @tree = tree
    end

    def to_s
      format(nil, @tree, 0)
    end

    def format(key, tree, level)
      spacer = "  " * level
      buffer = spacer + format_node(key, tree)
      tree.children.to_a.sort {|kv1, kv2| kv2[1].total_elapsed <=> kv1[1].total_elapsed}.each do |kv|
        buffer += format(kv[0], kv[1], level + 1)
      end
      buffer
    end

    def format_node(key, tree)
      "%.3fs for %d quer%s => %s    %s\n" %
      [
        tree.total_elapsed / 1000.0,
        tree.total_count,
        tree.total_count == 1 ? "y" : "ies",
        format_key(key),
        tree.records.map {|r| r.elapsed / 1000.0}.join(",  ")
      ]
    end

    def format_key(key)
      if key
        "%s (%s)" % [key.file_line, key.class_method.split('.').last]
#         key.class_method
        #          key.file_line,
      else
        "TOTAL"
      end
    end
  end
end


=begin
Only indent when there is more than one child. If only one child, don't 
=end
