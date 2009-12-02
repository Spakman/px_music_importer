# Copyright (C) 2009 Mark Somerville <mark@scottishclimbs.com>
# Released under the General Public License (GPL) version 3.
# See COPYING

require "rufus/tokyo"
require_relative "../lib/music_file"
require_relative "../lib/artist_formatter"
require_relative "../lib/support_checker"

class MusicImporter::Importer
  def initialize(music_directory, database_path)
    @music_directory = music_directory
    @database_path = database_path
    @current_directory = Dir.pwd
  end

  # Begin the import, starting at @music_directory.
  def import
    @table = Rufus::Tokyo::Table.new(@database_path)
    if last_row = @table.query.last
      @primary_key = last_row[:pk].to_i + 1
    else
      @primary_key = 1
    end
    Dir.chdir @music_directory
    import_directory Dir.pwd
    Dir.chdir @current_directory
    @table.close
  end

  # Imports an entire directory tree.
  def import_directory(directory_path)
    Dir.entries(directory_path).each do |entry|
      next if entry == ".." or entry == "."
      filepath = "#{directory_path}/#{entry}"
      if File.directory? filepath
        import_directory filepath
      else
        import_file filepath
      end
    end
  end

  # Imports a single file (assuming it is supported).
  def import_file(filepath)
    return false unless MusicImporter::SupportChecker.supported? filepath
    MusicImporter::MusicFile.open(filepath.split("#{Dir.pwd}/")[1], Dir.pwd) do |file|
      artist_name = ArtistFormatter::format_for_consistency(file.artist)

      rows = @table.query do |query|
        query.add_condition 'artist', :ftsphrase, artist_name
      end

      if rows.length > 0
        @table[@primary_key] = { artist: rows.first['artist'], album: file.album, track: file.title, genre: file.genre, track_nr: file.track_number, url: "file://#{filepath}" }
      else
        @table[@primary_key] = { artist: artist_name, album: file.album, track: file.title, genre: file.genre, track_nr: file.track_number, url: "file://#{filepath}" }
      end
      @primary_key += 1
    end
  end
end
