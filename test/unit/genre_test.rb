require File.dirname(__FILE__) + '/../test_helper'

class GenreTest < Test::Unit::TestCase
  fixtures :genres

  def setup
    @genre = Euterpe::Dashboard::Genre.find(1)
  end
  
  def test_basic
    assert_kind_of Euterpe::Dashboard::Genre, @genre
    assert_equal "Post Punk", @genre.name
    assert_equal 12, @genre.tracks.size
  end
end
