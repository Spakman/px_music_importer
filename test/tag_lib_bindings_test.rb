require 'test/unit'
require_relative "../lib/music_file"

class TagLibBindingsTest < Test::Unit::TestCase
  def test_read_ogg_tags
    MusicImporter::MusicFile.open "test/music/dlanod.ogg" do |file|
      assert_equal 1, file.track_number_from_tag
      assert_equal "Donald where's yer troosers? (in reverse)", file.title_from_tag
      assert_equal "Spakman", file.artist_from_tag
      assert_equal "Spakwards", file.album_from_tag
      assert_equal "Comedy", file.genre_from_tag
    end
  end

  def test_ogg_with_no_tags
    MusicImporter::MusicFile.open "unparsable_music/troosers.ogg", "test/music" do |file|
      assert_nil file.track_number_from_tag
      assert_nil file.title_from_tag
      assert_nil file.artist_from_tag
      assert_nil file.album_from_tag
      assert_nil file.genre_from_tag
    end
  end

  def test_read_mp3_tag
    MusicImporter::MusicFile.open "test/music/dlanod.mp3" do |file|
      assert_equal 1, file.track_number_from_tag
      assert_equal "Donald where's yer troosers? (in reverse)", file.title_from_tag
      assert_equal "Spakman", file.artist_from_tag
      assert_equal "Spakwards", file.album_from_tag
      assert_equal "Comedy", file.genre_from_tag
    end
  end

  def test_read_non_music_file
    MusicImporter::MusicFile.open "test/music/not_a_music_file" do |file|
      assert_nil file.track_number_from_tag
      assert_nil file.title_from_tag
      assert_nil file.artist_from_tag
      assert_nil file.album_from_tag
      assert_nil file.genre_from_tag
    end
  end
end
