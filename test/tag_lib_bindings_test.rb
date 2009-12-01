require 'test/unit'
require 'fileutils'
require_relative "../lib/music_file"

class TagLibBindingsTest < Test::Unit::TestCase
  def test_read_ogg_tags
    @file = MusicImporter::MusicFile.open "test/music/dlanod.ogg"
    assert_equal 1, @file.track_number_from_tag
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_tag
    assert_equal "Spakman", @file.artist_from_tag
    assert_equal "Spakwards", @file.album_from_tag
    assert_equal "Comedy", @file.genre_from_tag
  end

  def test_ogg_with_no_tags
    @file = MusicImporter::MusicFile.open "unparsable_music/troosers.ogg", "test/music"
    assert_nil @file.track_number_from_tag
    assert_nil @file.title_from_tag
    assert_nil @file.artist_from_tag
    assert_nil @file.album_from_tag
    assert_nil @file.genre_from_tag
  end

  def test_read_mp3_tag
    @file = MusicImporter::MusicFile.open "test/music/dlanod.mp3"
    assert_equal 1, @file.track_number_from_tag
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_tag
    assert_equal "Spakman", @file.artist_from_tag
    assert_equal "Spakwards", @file.album_from_tag
    assert_equal "Comedy", @file.genre_from_tag
  end

  def test_read_non_music_file
    @file = MusicImporter::MusicFile.open "test/music/not_a_music_file"
    assert_nil @file.track_number_from_tag
    assert_nil @file.title_from_tag
    assert_nil @file.artist_from_tag
    assert_nil @file.album_from_tag
    assert_nil @file.genre_from_tag
  end
end
