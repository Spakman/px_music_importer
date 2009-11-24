require 'test/unit'
require 'fileutils'
require_relative "../lib/tagged_file"

class TagLibBindingsTest < Test::Unit::TestCase
  def test_read_ogg_tags
    @file = MusicImporter::TaggedFile.open "test/music/dlanod.ogg"
    assert_equal 1, @file.track_number_from_tag
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_tag
    assert_equal "Spakman", @file.artist_from_tag
    assert_equal "Spakwards", @file.album_from_tag
    assert_equal "Comedy", @file.genre_from_tag
  end

  def test_read_mp3_tag
    @file = MusicImporter::TaggedFile.open "test/music/dlanod.mp3"
    assert_equal 1, @file.track_number_from_tag
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_tag
    assert_equal "Spakman", @file.artist_from_tag
    assert_equal "Spakwards", @file.album_from_tag
    assert_equal "Comedy", @file.genre_from_tag
  end
end
