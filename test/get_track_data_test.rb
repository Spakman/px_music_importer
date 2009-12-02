require 'test/unit'
require 'fileutils'
require_relative "../lib/music_file"

# When getting track information, we first try to read the tag, then infer from
# the filepath. If that fails, just call it "Unknown".
#
# There are other tests to test the tag reading and filepath stuff.
class GetTrackDataTest < Test::Unit::TestCase
  def test_from_tag
    MusicImporter::MusicFile.open "test/music/dlanod.ogg" do |file|
      assert_equal "Spakman", file.artist
      assert_equal "Spakwards", file.album
      assert_equal "Donald where's yer troosers? (in reverse)", file.title
      assert_equal "Comedy", file.genre
      assert_equal 1, file.track_number
    end
  end

  def test_from_path
    MusicImporter::MusicFile.open "Spakman - Spakwards/01 - Donald where's yer troosers? (in reverse).ogg", "test/music" do |file|
      assert_equal "Spakman", file.artist
      assert_equal "Spakwards", file.album
      assert_equal "Donald where's yer troosers? (in reverse)", file.title
      assert_equal "Unknown", file.genre
      assert_equal 1, file.track_number
    end
  end

  def test_without_tag_or_path_data
    MusicImporter::MusicFile.open "unparsable_music/troosers.ogg", "test/music" do |file|
      assert_equal "Unknown", file.artist
      assert_equal "Unknown", file.album
      assert_equal "Unknown", file.title
      assert_equal "Unknown", file.genre
      assert_nil file.track_number
    end
  end
end
