# coding: utf-8
require 'test/unit'
require 'fileutils'
require_relative "../lib/tagged_file"

class TrackDataFromPathTest < Test::Unit::TestCase
  def test_artist_hyphen_album_directory_structure
    @file = MusicImporter::TaggedFile.open "Spakman - Spakwards/01 - Donald where's yer troosers? (in reverse).ogg", "test/music"
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_path
    assert_equal "Spakman", @file.artist_from_path
    assert_equal "Spakwards", @file.album_from_path
    assert_equal 1, @file.track_number_from_path
  end

  def test_with_track_number_without_spaces
    @file = MusicImporter::TaggedFile.open "Spakman - Spakwards/01-Donald where's yer troosers? (in reverse).ogg", "test/music"
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_path
    assert_equal "Spakman", @file.artist_from_path
    assert_equal "Spakwards", @file.album_from_path
    assert_equal 1, @file.track_number_from_path
  end

  def test_without_track_number
    @file = MusicImporter::TaggedFile.open "Spakman - Spakwards/Donald where's yer troosers? (in reverse).ogg", "test/music"
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_path
    assert_equal "Spakman", @file.artist_from_path
    assert_equal "Spakwards", @file.album_from_path
    assert_nil @file.track_number_from_path
  end

  def test_with_underscores_instead_of_spaces
    @file = MusicImporter::TaggedFile.open "Spakman - Spakwards/01_-_Donald_where's_yer_troosers?_(in_reverse).ogg", "test/music"
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_path
    assert_equal "Spakman", @file.artist_from_path
    assert_equal "Spakwards", @file.album_from_path
    assert_equal 1, @file.track_number_from_path
  end

  def test_with_underscores_instead_of_spaces_for_whole_path
    @file = MusicImporter::TaggedFile.open "Spakman_-_Spakwards/01_-_Donald_where's_yer_troosers?_(in_reverse).ogg", "test/music"
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_path
    assert_equal "Spakman", @file.artist_from_path
    assert_equal "Spakwards", @file.album_from_path
    assert_equal 1, @file.track_number_from_path
  end

  def test_unicode_character_in_filename
    @file = MusicImporter::TaggedFile.open "Spakman_-_Spakwards/02_-_1cøde.ogg", "test/music"
    assert_equal "1cøde", @file.title_from_path
    assert_equal "Spakman", @file.artist_from_path
    assert_equal "Spakwards", @file.album_from_path
    assert_equal 2, @file.track_number_from_path
  end

  def test_artist_album_tracks_directory_structure
    @file = MusicImporter::TaggedFile.open "Spakman/Spakwards/01 - Donald where's yer troosers? (in reverse).ogg", "test/music"
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_path
    assert_equal "Spakman", @file.artist_from_path
    assert_equal "Spakwards", @file.album_from_path
    assert_equal 1, @file.track_number_from_path
  end

  def test_artist_album_tracks_directory_structure_with_underscores_instead_of_spaces
    @file = MusicImporter::TaggedFile.open "Spakman/Spakwards/01_-_Donald_where's_yer_troosers?_(in_reverse).ogg", "test/music"
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_path
    assert_equal "Spakman", @file.artist_from_path
    assert_equal "Spakwards", @file.album_from_path
    assert_equal 1, @file.track_number_from_path
  end

  def test_artist_album_tracks_directory_structure_with_period_after_track_number
    @file = MusicImporter::TaggedFile.open "Spakman/Spakwards/01. - Donald where's yer troosers? (in reverse).ogg", "test/music"
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_path
    assert_equal "Spakman", @file.artist_from_path
    assert_equal "Spakwards", @file.album_from_path
    assert_equal 1, @file.track_number_from_path

    @file = MusicImporter::TaggedFile.open "Spakman/Spakwards/01.Donald where's yer troosers? (in reverse).ogg", "test/music"
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_path
    assert_equal "Spakman", @file.artist_from_path
    assert_equal "Spakwards", @file.album_from_path
    assert_equal 1, @file.track_number_from_path
  end

  def test_artist_then_artist_track_structure_without_track_number
    @file = MusicImporter::TaggedFile.open "Spakman/Spakman - Donald where's yer troosers? (in reverse).ogg", "test/music"
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_path
    assert_equal "Spakman", @file.artist_from_path
    assert_equal nil, @file.album_from_path
    assert_equal nil, @file.track_number_from_path
  end

  def test_artist_then_artist_track_structure_with_track_number
    @file = MusicImporter::TaggedFile.open "Spakman/Spakman - 01 - Donald where's yer troosers? (in reverse).ogg", "test/music"
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_path
    assert_equal "Spakman", @file.artist_from_path
    assert_equal nil, @file.album_from_path
    assert_equal 1, @file.track_number_from_path
  end

  def test_artist_then_artist_track_structure_with_track_number_no_spaces_around_hyphens
    @file = MusicImporter::TaggedFile.open "Spakman/Spakman-01-Donald where's yer troosers? (in reverse).ogg", "test/music"
    assert_equal "Donald where's yer troosers? (in reverse)", @file.title_from_path
    assert_equal "Spakman", @file.artist_from_path
    assert_equal nil, @file.album_from_path
    assert_equal 1, @file.track_number_from_path
  end
end
