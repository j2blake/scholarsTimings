=begin
--------------------------------------------------------------------------------

Accept path to log file from command line.

Request start time and end time interactively, defaulting to the entire file.

Process the logged queries and display the tree and other info.

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
=end

$: << File.dirname(File.expand_path(__FILE__))

require 'date'

require 'query_log_reader/arguments'
require 'query_log_reader/log_record'
require 'query_log_reader/raw_tree'
require 'query_log_reader/tree_refiner'
require 'query_log_reader/formatter'

module QueryLogReader
  # What did you ask for?
  class UserInputError < StandardError
  end

  class Main
    def initialize
    end

    def run
      begin
        args = Arguments.new(ARGV)
        records = LogRecord.parseRecords(args)
        tree = RawTree.build(records)
        refined = TreeRefiner.new.refine(tree)
        puts Formatter.new(refined)
      rescue UserInputError
        puts
        puts "ERROR: #{$!}"
        puts
        exit 1
      end
    end
  end
end






=begin

2017-05-11 11:46:39,768 INFO  [RDFServiceLogger]    0.002 sparqlConstructQuery [         PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>         CONSTRUCT {              <http://scholars.cornell.edu/individual/org73341> <http://purl.obolibrary.org/obo/ARG_2000028> ?vcard .             ?vcard vcard:hasTelephone ?phone .             ?phone ?phoneProperty ?phoneValue          } WHERE {                <http://scholars.cornell.edu/individual/org73341> <http://purl.obolibrary.org/obo/ARG_2000028> ?vcard .                ?vcard vcard:hasTelephone ?phone .                ?phone ?phoneProperty ?phoneValue          }      ]    edu.cornell.mannlib.vitro.webapp.rdfservice.impl.logging.LoggingRDFService.sparqlConstructQuery(LoggingRDFService.java:53) 
   edu.cornell.mannlib.vitro.webapp.dao.jena.ObjectPropertyStatementDaoJena.constructModelForSelectQueries(ObjectPropertyStatementDaoJena.java:455) 
   edu.cornell.mannlib.vitro.webapp.dao.jena.ObjectPropertyStatementDaoJena.getObjectPropertyStatementsForIndividualByProperty(ObjectPropertyStatementDaoJena.java:290) 
   edu.cornell.mannlib.vitro.webapp.dao.filtering.ObjectPropertyStatementDaoFiltering.getObjectPropertyStatementsForIndividualByProperty(ObjectPropertyStatementDaoFiltering.java:93) 
   edu.cornell.mannlib.vitro.webapp.web.templatemodels.individual.ObjectPropertyTemplateModel.getStatementData(ObjectPropertyTemplateModel.java:166) 
   edu.cornell.mannlib.vitro.webapp.web.templatemodels.individual.UncollatedObjectPropertyTemplateModel.<init>(UncollatedObjectPropertyTemplateModel.java:35) 
   edu.cornell.mannlib.vitro.webapp.web.templatemodels.individual.ObjectPropertyTemplateModel.getObjectPropertyTemplateModel(ObjectPropertyTemplateModel.java:256) 
   edu.cornell.mannlib.vitro.webapp.web.templatemodels.individual.PropertyGroupTemplateModel.<init>(PropertyGroupTemplateModel.java:54) 
   edu.cornell.mannlib.vitro.webapp.web.templatemodels.individual.GroupedPropertyList.<init>(GroupedPropertyList.java:140) 
   edu.cornell.mannlib.vitro.webapp.web.templatemodels.individual.BaseIndividualTemplateModel.getPropertyList(BaseIndividualTemplateModel.java:109) 
   sun.reflect.NativeMethodAccessorImpl.invoke0(NativeMethodAccessorImpl.java:-2) 
   sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62) 
   sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43) 
   java.lang.reflect.Method.invoke(Method.java:498) 
   freemarker.ext.beans.BeansWrapper.invokeMethod(BeansWrapper.java:866) 
   freemarker.ext.beans.BeanModel.invokeThroughDescriptor(BeanModel.java:277) 
   freemarker.ext.beans.BeanModel.get(BeanModel.java:184) 
   freemarker.core.Dot._getAsTemplateModel(Dot.java:76) 
   freemarker.core.Expression.getAsTemplateModel(Expression.java:89) 
   freemarker.core.Assignment.accept(Assignment.java:90) 
   freemarker.core.Environment.visit(Environment.java:221) 
   freemarker.core.MixedContent.accept(MixedContent.java:92) 
   freemarker.core.Environment.visit(Environment.java:221) 
   freemarker.core.Environment.include(Environment.java:1508) 
   freemarker.core.Include.accept(Include.java:169) 
   freemarker.core.Environment.visit(Environment.java:221) 
   freemarker.core.MixedContent.accept(MixedContent.java:92) 
   freemarker.core.Environment.visit(Environment.java:221) 
   freemarker.core.Environment.process(Environment.java:199) 
   edu.cornell.mannlib.vitro.webapp.controller.freemarker.TemplateProcessingHelper.processTemplate(TemplateProcessingHelper.java:58) 
   edu.cornell.mannlib.vitro.webapp.controller.freemarker.TemplateProcessingHelper.processTemplate(TemplateProcessingHelper.java:37) 
   edu.cornell.mannlib.vitro.webapp.controller.freemarker.FreemarkerHttpServlet.processTemplate(FreemarkerHttpServlet.java:509) 
   edu.cornell.mannlib.vitro.webapp.controller.freemarker.FreemarkerHttpServlet.processTemplateToString(FreemarkerHttpServlet.java:515) 
   edu.cornell.mannlib.vitro.webapp.controller.freemarker.FreemarkerHttpServlet.doTemplate(FreemarkerHttpServlet.java:278) 
   edu.cornell.mannlib.vitro.webapp.controller.freemarker.FreemarkerHttpServlet.doResponse(FreemarkerHttpServlet.java:238) 
   edu.cornell.mannlib.vitro.webapp.controller.freemarker.FreemarkerHttpServlet.doGet(FreemarkerHttpServlet.java:112) 
   javax.servlet.http.HttpServlet.service(HttpServlet.java:621) 
   javax.servlet.http.HttpServlet.service(HttpServlet.java:728) 
   edu.cornell.mannlib.vitro.webapp.controller.VitroHttpServlet.service(VitroHttpServlet.java:71) 
   org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:305) 
   ...

Becomes:



2017-05-11 11:46:39,768 INFO  [RDFServiceLogger]    0.002 sparqlConstructQuery [
         PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
         CONSTRUCT {
              <http://scholars.cornell.edu/individual/org73341> <http://purl.obolibrary.org/obo/ARG_2000028> ?vcard .
             ?vcard vcard:hasTelephone ?phone .
             ?phone ?phoneProperty ?phoneValue
          } WHERE {
                <http://scholars.cornell.edu/individual/org73341> <http://purl.obolibrary.org/obo/ARG_2000028> ?vcard .
                ?vcard vcard:hasTelephone ?phone .
                ?phone ?phoneProperty ?phoneValue
          }
]
100.0% ................ ApplicationFilterChain.java:305
                              140 3.016
   98.1% ................. VitroHttpServlet.java:71
                                  25 0.805 
     96.3% ................. HttpServlet.java:728
                                     4  2.602
    1.9% ................. HttpServlet.java:621
                                 115 0.004 q1 q2 q42

List the queries
Rank them by:
   Longest individual query
   Longest aggregate query

First pass -- build the raw data tree
-- Specify the time range.
   -- Allow substring matching
   -- If not specified, use the entire file.
-- A logging is
   -- starts with a line that contains "[RDFServiceLogger]"
   -- ends with line that is "..." after trimming
   -- time-stamp, elapsed time, query string, stack
-- The data tree.
   -- a record for each logging within the time range
   -- entries include all steps in the stack trace, filename:line
      -- subtract .java from the filename
      -- bottom entry is the query data itself.
   -- as each logging is added, duplicate nodes are re-used, or new ones created.
-- count the queries, get the time summary.
   
Second passes -- refine the tree
-- canonicalize queries at nodes
-- recursively determine counts and elapsed times
-- recursively determine percentage time
-- trim nodes (remove all but edu.cornell.mannlib?) 
-- trim nodes (recursively remove singleton leaves?)

=end