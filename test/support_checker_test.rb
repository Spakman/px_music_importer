require 'test/unit'
require 'fileutils'
require_relative "../lib/support_checker"

class SupportCheckerTest < Test::Unit::TestCase
  def test_support_ogg
    assert MusicImporter::SupportChecker.supported? "test/music/dlanod.ogg"
  end

  def test_support_mp3
    assert MusicImporter::SupportChecker.supported? "test/music/dlanod.mp3"
  end

  def test_do_no_support_text
    assert !MusicImporter::SupportChecker.supported?(__FILE__)
  end
end
