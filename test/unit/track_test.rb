require File.dirname(__FILE__) + '/../test_helper'

class TrackTest < Test::Unit::TestCase
  fixtures :albums, :discs, :media_paths, :tracks

  def setup
    @track = Track.find(1)
  end
  
  def test_basic
    assert_kind_of Track, @track
    assert_equal "Formed A Band", @track.name
    assert_equal 1, @track.sequence
    assert_kind_of Disc, @track.disc
    assert_equal 1, @track.disc.number
    assert_equal "2005", @track.release_date
    assert_equal "Bang Bang Rock & Roll", @track.disc.album.name
  end
end
