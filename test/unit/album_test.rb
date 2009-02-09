require File.dirname(__FILE__) + '/../test_helper'

class AlbumTest < Test::Unit::TestCase
  fixtures :genres, :albums, :discs, :tracks

  def setup
    @album = Album.find(1)
  end
  
  def test_basic
    assert_kind_of Album, @album
    assert_equal "Bang Bang Rock & Roll", @album.name
    assert_equal 1, @album.discs.size
    assert_equal 1, @album.discs.first.number
    assert_equal 12, @album.discs.first.number_of_tracks
    assert_equal 12, @album.discs.first.tracks.size
  end
end
