module ModelSummary
  class Stats
    TYPE = RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type")

    def initialize(graph)
      @number_of_statements = graph.count
      @subjects = Hash.new(0)
      @predicates = Hash.new(0)
      @types = Hash.new(0)
      graph.each() do |stmt|
        subject, predicate, object = stmt.to_triple
        @subjects[subject] += 1
        @predicates[predicate] += 1
        @types[object] += 1 if predicate == TYPE
      end
    end
    def to_s
      s = "Statement count: #{@number_of_statements}\n"
      s += "Distinct subjects: #{@subjects.keys.size}\n"
      s += "Distinct predicates: #{@predicates.keys.size}\n"
      s += "Distinct types: #{@types.keys.size}\n"
      s += listPredicates + listTypes + "\n"
    end

    def listPredicates
      s = "\nPREDICATES\n"
      @predicates.keys.sort.each do |p|
        s += "#{@predicates[p]}  #{p}\n"
      end
      s
    end

    def listTypes
      s = "\nTYPES\n"
      @types.keys.sort.each do |t|
        s += "#{@types[t]}  #{t}\n"
      end
      s
    end
  end
end
