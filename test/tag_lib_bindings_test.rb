require 'test/unit'
require 'fileutils'
require_relative "../lib/tagged_file"

class TagLibBindingsTest < Test::Unit::TestCase
  def test_read_ogg_tags
    @file = MusicImporter::TaggedFile.open "test/dlanod.ogg"
    assert_equal 1, @file.track_number
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title
    assert_equal "Spakman", @file.artist
    assert_equal "Spakwards", @file.album
    assert_equal "Comedy", @file.genre
  end

  def test_read_mp3_tag
    @file = MusicImporter::TaggedFile.open "test/dlanod.mp3"
    assert_equal 1, @file.track_number
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title
    assert_equal "Spakman", @file.artist
    assert_equal "Spakwards", @file.album
    assert_equal "Comedy", @file.genre
  end
end
