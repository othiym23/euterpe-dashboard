#!/usr/bin/env ruby

require 'net/http'
require 'rexml/document'

MUSICBRAINZ_URI = 'http://musicbrainz.org/cgi-bin/mq_2_1.pl'

module MusicBrainz
  class Fetcher
    attr_accessor :album_cache, :artist_cache, :track_cache
  
    def initialize
      @album_cache = {}
      @artist_cache = {}
      @track_cache = {}
    end

    def self.post_to_server(url_string, query_string)
      url = URI.parse( url_string )

      Net::HTTP.start( url.host, url.port ) do |http|
        http.post( url.path, query_string )
      end
    end

    def self.get_from_server(url_string)
      url = URI.parse( url_string )

      Net::HTTP.start( url.host, url.port ) do |http|
        http.get( url.path )
      end
    end

    def self.get_xml_from_server(url_string)
      res = get_from_server(url_string)

      REXML::Document.new(res.body).root
    end

    def album_from_rdf(album_reference)
      @album_cache[album_reference] ||= self.class.get_xml_from_server(album_reference).root.elements['mm:Album']
    end

    def track_from_rdf(track_reference)
      @track_cache[track_reference] ||= self.class.get_xml_from_server(track_reference).root.elements['mm:Track']
    end

    def artist_from_rdf(artist_reference)
      @artist_cache[artist_reference] ||= self.class.get_xml_from_server(artist_reference).root.elements['mm:Artist'] 
    end
  end
  
  class Base
    attr_accessor :reference

    @@fetcher = Fetcher.new
    
    def self.fetcher=(fetcher)
      @@fetcher = fetcher
    end
    
    def self.fetcher
      @@fetcher
    end
    
    protected
    
    def self.create_query_template(query_type)
      doc = REXML::Document.new
      doc << REXML::XMLDecl.new

      rdf = doc.add_element "rdf:RDF"

      rdf.attributes["xmlns:rdf"] = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      rdf.attributes["xmlns:dc"]  = "http://purl.org/dc/elements/1.1/"
      rdf.attributes["xmlns:mq"]  = "http://musicbrainz.org/mm/mq-1.1#"
      rdf.attributes["xmlns:mm"]  = "http://musicbrainz.org/mm/mm-2.1#"

      rdf.add_element "mq:#{query_type}"
    end
  end

  class Artist < Base
    def Artist.search(artist_string)
      result_root = find(artist_string, 5)

      puts "Parsing results from server with size #{result_root.to_s.size}"

      album_references = result_root.elements.to_a('//mm:Artist/mm:albumList/rdf:Bag/rdf:li').collect { |album_reference| album_reference.attributes['rdf:resource'] }
      puts "#{album_references.size} reference(s) to albums."
      
      albums = []
      album_references.each do |reference|
        albums << Album.new(reference, result_root)
      end
      
      albums
    end

    def initialize(reference)
      @reference = reference
      @rdf = self.class.fetcher.artist_from_rdf(@reference)
    end
    
    def id
      @reference.match(/http:\/\/musicbrainz.org\/mm-2\.1\/artist\/(.+)/)[1]
    end
    
    def name
      @rdf.elements["dc:title"].text
    end
    
    private
    
    def Artist.find(artist_name, depth = 1)
      query = create_query_template "FindArtist"

      query.add_element("mq:depth").text = depth
      query.add_element("mq:artistName").text = artist_name

      res = fetcher.class.post_to_server(MUSICBRAINZ_URI, query.root.to_s)

      REXML::Document.new(res.body).root
    end
  end
  
  class Track < Base
    def initialize(reference)
      @reference = reference
      @rdf = self.class.fetcher.track_from_rdf(@reference)
    end
    
    def id
      @reference.match(/http:\/\/musicbrainz.org\/mm-2\.1\/track\/(.+)/)[1]
    end
    
    def name
      @rdf.elements["dc:title"].text
    end
    
    def artist_reference
      @rdf.elements['dc:creator'].attributes['rdf:resource']
    end

    def artist
      Artist.new(artist_reference)
    end
  end
  
  class Album < Base
    attr_reader :tracks
    
    def Album.search(artist_string, album_string, exact = false)
      result_root = find(artist_string, album_string, 3)
      puts "Parsing results from server with size #{result_root.to_s.size}"

      album_references = result_root.elements.to_a('//mq:Result/mm:albumList/rdf:Bag/rdf:li').collect { |album_reference| album_reference.attributes['rdf:resource'] }
      puts "#{album_references.size} reference(s) to albums."
      
      albums = []
      album_references.each do |reference|
        albums << self.new(reference, result_root)
      end
      
      if exact
        albums.select do |album|
          (album.artist.name.downcase == artist_string.downcase || album.artist.name.downcase == 'various artists') &&
          album.name.downcase == album_string.downcase
        end
      else
        albums
      end
    end

    def initialize(reference, rdf_root)
      @reference = reference
      @rdf_root = rdf_root
      @rdf = self.class.fetcher.album_from_rdf(@reference)
      @tracks = []
    end
    
    def id
      @reference.match(/http:\/\/musicbrainz.org\/mm-2\.1\/album\/(.+)/)[1]
    end
    
    def name
      @rdf.elements["dc:title"].text
    end
    
    def artist_reference
      @rdf.elements['dc:creator'].attributes['rdf:resource']
    end
    
    def artist
      Artist.new(artist_reference)
    end
    
    def tracks
      if @tracks.size == 0
        track_references.each do |reference|
          @tracks << MusicBrainz::Track.new(reference)
        end
      end
      @tracks
    end
    
    private
    
    def Album.find(artist_name, album_name, depth = 1)
      query = create_query_template "FindAlbum"

      query.add_element("mq:depth").text = depth
      query.add_element("mq:artistName").text = artist_name
      query.add_element("mq:albumName").text = album_name

      res = fetcher.class.post_to_server(MUSICBRAINZ_URI, query.root.to_s)

      REXML::Document.new(res.body).root
    end

    def track_references
      @rdf_root.elements.to_a("mm:Album[@rdf:about='#{reference}']/mm:trackList/rdf:Seq/rdf:li").collect do |track_reference|
        track_reference.attributes['rdf:resource']
      end
    end
  end
end

query_artist = ARGV[0]
query_album = ARGV[1]

puts "Querying MusicBrainz for #{query_artist} - #{query_album}"

MusicBrainz::Base.fetcher = MusicBrainz::Fetcher.new

albums = []
if query_album.nil? || query_album == ''
  albums = MusicBrainz::Artist.search(query_artist)
else
  albums = MusicBrainz::Album.search(query_artist, query_album, true)
  if albums.size == 0
    albums = MusicBrainz::Album.search(query_artist, query_album, false)
  end
end

albums.each do |album|
  puts "#{album.artist.name} {#{album.artist.id}} - #{album.name} {#{album.id}} (#{album.tracks.size} tracks)"
  album.tracks.each_with_index do |track,index|
    line = "  #{index + 1}. "
    line << "#{track.artist.name} - " if track.artist.name != album.artist.name
    line << track.name
    line << " {#{track.id}}"

    puts line
  end

  puts
end

puts "Dumping artist cache:"

MusicBrainz::Base.fetcher.artist_cache.values.sort{|l,r| l.elements["mm:sortName"].text <=> r.elements["mm:sortName"].text}.each do |artist|
  puts "a: #{artist.elements["dc:title"].text} {#{artist.attributes['rdf:about'].match(/http:\/\/musicbrainz.org\/mm-2\.1\/artist\/(.+)/)[1]}}"
end
