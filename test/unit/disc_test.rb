require File.dirname(__FILE__) + '/../test_helper'

class DiscTest < Test::Unit::TestCase
  fixtures :albums, :discs, :tracks

  def setup
    @disc = Euterpe::Dashboard::Disc.find(1)
  end
  
  def test_basic
    assert_kind_of Euterpe::Dashboard::Disc, @disc
    assert_equal 1, @disc.number
    assert_equal 12, @disc.number_of_tracks
    assert_equal 12, @disc.tracks.size
    assert_equal "Bang Bang Rock & Roll", @disc.album.name
  end
end
