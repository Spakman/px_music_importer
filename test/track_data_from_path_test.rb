require 'test/unit'
require 'fileutils'
require_relative "../lib/tagged_file"

class TrackDataFromPathTest < Test::Unit::TestCase
  def test_infer_all_data_from_path_and_filename
    @file = MusicImporter::TaggedFile.open "Spakman - Spakwards/01 - Donald where's yer troosers? (in reverse).ogg", "test/music"
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_path
    assert_equal "Spakman", @file.artist_from_path
    assert_equal "Spakwards", @file.album_from_path
    assert_equal 1, @file.track_number_from_path
  end
end
