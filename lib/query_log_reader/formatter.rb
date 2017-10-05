module QueryLogReader
  class Formatter
    def initialize(tree)
      @tree = tree
    end

    def to_s
      format_tree(nil, @tree, -1, true)
    end

    def format_tree(key, tree, level, newBranch)
      if newBranch
        level += 1
        buffer = format_new_branch(key, tree, level)
      else
        buffer = format_same_branch(key, tree, level)
      end

      children = tree.children.to_a.sort {|kv1, kv2| kv2[1].total_elapsed <=> kv1[1].total_elapsed}
      if children.length == 1
        kv = children[0]
        buffer += format_tree(kv[0], kv[1], level, false)
      else
        children.each do |kv|
          buffer += format_tree(kv[0], kv[1], level, true)
        end
      end
      buffer
    end

    def format_new_branch(key, tree, level)
      "%s%7.3fs for %3d %s => %s\n%s" %
      [
        "    " * level,
        tree.total_elapsed / 1000.0,
        tree.total_count,
        tree.total_count == 1 ? "query  " : "queries",
        format_key(key),
        format_record_references(tree.records, level)
      ]
    end

    def format_same_branch(key, tree, level)
      "%s                            %s\n%s" %
      [
        "    " * level,
        format_key(key),
        format_record_references(tree.records, level)
      ]
    end

    def format_key(key)
      if key
        "%s (%s)" % [key.file_line, key.class_method.split('.').last]
      else
        "TOTAL"
      end
    end

    def format_record_references(records, level)
      if records && records.size > 0
        "%s                                %s\n" %
        [
          "    " * level,
          records.map {|r| r.elapsed / 1000.0}.join(", ")
        ]
      else
        ""
      end
    end
  end
end

=begin
Only indent when there is more than one child. If only one child, don't print stats

If new branch,
  indent, print the line with stats, recurse
else
  print the line without stats, recurse

Recursion:
  get the sorted children array
  if 0, nothing
  if one, format with no new branch
  if more format with new branch
=end
