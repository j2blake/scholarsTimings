module QueryLogReader
  class TreeRefiner
    def refine(raw_tree)
      puts "BOGUS RefinedTree.initialize()"
      tree = raw_tree
      tree = prune_singleton_leaves(tree)
    end

    #
    # If a node has only one child, and that child has no children, 
    # then the child may be deleted, and the child's LogRecords given
    # to the parent node.
    #
    # Apply recursively.
    #  
    def prune_singleton_leaves(tree)
      tree.children.values.each do |child|
        prune_singleton_leaves(child)
      end
      if tree.children.size == 1
        remove_child_if_eligible(tree)
      end
      tree
    end

    def remove_child_if_eligible(tree)
      child = tree.children.values[0]
      if tree.records.empty? && child.children.empty?
        tree.records = child.records
        tree.total_count = child.total_count
        tree.total_elapsed = child.total_elapsed
        tree.children.clear
      end
      tree
    end
  end
end

#  attr_accessor :children
#  attr_accessor :records
#  attr_accessor :total_count
#  attr_accessor :total_elapsed

#    attr_accessor :stamp
#    attr_accessor :elapsed
#    attr_accessor :query
#    attr_accessor :query_type
#    attr_accessor :response_type
#    attr_accessor :trace

#        attr_accessor :class_method
#        attr_accessor :file_line

=begin
Second passes -- refine the tree
-- canonicalize queries at nodes
-- trim nodes (remove all but edu.cornell.mannlib?)

For all query strings on a given node
Split on white space into tokens
Find positions with mismatched tokens.
If more than one quarter are mismatched, complain
In the mismatched positions, assign variables -- perhaps the same variable in more than one place.

If class_method does not begin with edu.cornell
Collapse any 
=end