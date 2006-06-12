#!/usr/bin/env ruby

require 'net/http'
require 'rexml/document'

doc = REXML::Document.new
doc << REXML::XMLDecl.new

rdf_root = doc.add_element "rdf:RDF"

rdf_root.attributes["xmlns:rdf"] = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
rdf_root.attributes["xmlns:dc"]  = "http://purl.org/dc/elements/1.1/"
rdf_root.attributes["xmlns:mq"]  = "http://musicbrainz.org/mm/mq-1.1#"
rdf_root.attributes["xmlns:mm"]  = "http://musicbrainz.org/mm/mm-2.1#"

query_root = rdf_root.add_element "mq:FindAlbum"

query_root.add_element("mq:depth").text = 5
query_root.add_element("mq:artistName").text = "Björk"
query_root.add_element("mq:albumName").text = "Homogenic"

url = URI.parse( "http://musicbrainz.org/cgi-bin/mq_2_1.pl" )

res = Net::HTTP.start( url.host, url.port ) do |http|
  http.post( url.path, doc.to_s )
end

puts res