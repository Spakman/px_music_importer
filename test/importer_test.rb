require 'test/unit'
require 'fileutils'
require_relative "../lib/importer"

class ImporterTest < Test::Unit::TestCase
  def setup
    @database_path = "test/music.tct"
  end

  def test_import_directory
    MusicImporter::Importer.new("test/music/for_import", "test/music.tct").import
    @table = Rufus::Tokyo::Table.new(@database_path, :mode => 'r')
    all_tracks = @table.query
    assert_equal 2, all_tracks.size
    assert_equal 1, all_tracks.map { |t| t['artist'] }.uniq.size
    assert_equal 1, all_tracks.map { |t| t['album'] }.uniq.size
  end

  def test_import_two_directories
    MusicImporter::Importer.new("test/music/for_import", "test/music.tct").import
    MusicImporter::Importer.new("test/music/more_for_import", "test/music.tct").import
    @table = Rufus::Tokyo::Table.new(@database_path, :mode => 'r')
    all_tracks = @table.query
    assert_equal 3, all_tracks.size
    assert_equal 2, all_tracks.map { |t| t['artist'] }.uniq.size
    assert_equal 2, all_tracks.map { |t| t['album'] }.uniq.size
  end

  def teardown
    @table.close
    FileUtils.rm @database_path
  end
end
