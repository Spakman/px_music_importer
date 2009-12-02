require 'test/unit'
require_relative "../lib/artist_formatter"

class ArtistFormatterTest < Test::Unit::TestCase
  def test_remove_the_from_start_of_name
    assert_equal "Beatles", ArtistFormatter::format_for_consistency("The Beatles")
    assert_equal "Beatles", ArtistFormatter::format_for_consistency("the Beatles")
    assert_equal "Beatles", ArtistFormatter::format_for_consistency("Beatles, The")
    assert_equal "Beatles", ArtistFormatter::format_for_consistency("Beatles, the")
  end

  def test_capitalise_dj
    assert_equal "DJ Spakman", ArtistFormatter::format_for_consistency("Dj Spakman")
    assert_equal "DJ Spakman", ArtistFormatter::format_for_consistency("dj Spakman")
    assert_equal "DJ Spakman", ArtistFormatter::format_for_consistency("D.J. Spakman")
    assert_equal "We love DJ Spakman", ArtistFormatter::format_for_consistency("We love dj Spakman")
  end

  def test_remove_periods
    assert_equal "MR Spakman", ArtistFormatter::format_for_consistency("M.R. Spakman")
  end

  def test_replace_and_with_ampersand
    assert_equal "Ruby & C", ArtistFormatter::format_for_consistency("Ruby and C")
    assert_equal "Ruby & C", ArtistFormatter::format_for_consistency("Ruby And C")
    assert_equal "Ruby & C", ArtistFormatter::format_for_consistency("Ruby AND C")
  end

  def test_remove_featuring_another_artist
    assert_equal "DJ Spakman", ArtistFormatter::format_for_consistency("DJ Spakman featuring Jesus")
    assert_equal "DJ Spakman", ArtistFormatter::format_for_consistency("DJ Spakman feat Jesus")
    assert_equal "DJ Spakman", ArtistFormatter::format_for_consistency("DJ Spakman feat. Jesus")
    assert_equal "DJ Spakman", ArtistFormatter::format_for_consistency("DJ Spakman FEAT Jesus")
    assert_equal "DJ Spakman", ArtistFormatter::format_for_consistency("DJ Spakman FEAT. Jesus")
    assert_equal "Many Features to Use", ArtistFormatter::format_for_consistency("Many Features to Use")
  end

  def test_remove_vs_another_artist
    assert_equal "DJ Spakman", ArtistFormatter::format_for_consistency("DJ Spakman versus Jesus")
    assert_equal "DJ Spakman", ArtistFormatter::format_for_consistency("DJ Spakman vs Jesus")
    assert_equal "DJ Spakman", ArtistFormatter::format_for_consistency("DJ Spakman vs. Jesus")
    assert_equal "DJ Spakman", ArtistFormatter::format_for_consistency("DJ Spakman VS Jesus")
    assert_equal "DJ Spakman", ArtistFormatter::format_for_consistency("DJ Spakman VS. Jesus")
  end
end
