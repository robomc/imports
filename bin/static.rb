require './lib/inports'

@p = Processor.new(:handlers => EzPub::HandlerSets::Static)

puts $term.color("Starting static file ingest...", :green)

@p.ingest

@p.log_unhandled

puts $term.color("Static file ingest complete.", :green)

puts $term.color("Generating XML...", :green)

path = @p.to_xml :name => 'techlink-images-and-files'

puts $term.color("XML created at #{path}.", :green)
