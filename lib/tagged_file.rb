# Copyright (C) 2009 Mark Somerville <mark@scottishclimbs.com>
# Released under the General Public License (GPL) version 3.
# See COPYING

require 'ffi'

module MusicImporter
  class TaggedFile
    attr_reader :title_from_path, :artist_from_path, :album_from_path, :track_number_from_path
    extend FFI::Library
    ffi_lib "tag_c"
    attach_function :taglib_file_new, [ :string ], :pointer
    attach_function :taglib_file_tag, [ :pointer ], :pointer
    attach_function :taglib_tag_track, [ :pointer ], :uint
    attach_function :taglib_tag_title, [ :pointer ], :string
    attach_function :taglib_tag_artist, [ :pointer ], :string
    attach_function :taglib_tag_album, [ :pointer ], :string
    attach_function :taglib_tag_genre, [ :pointer ], :string

    def initialize(path, collection_root)
      collection_root = "#{collection_root}/" unless collection_root.empty?
      @path = path
      parse path
      @taglib_file = taglib_file_new("#{collection_root}#{@path}")
    end

    def self.open(path, collection_root = "")
      new path, collection_root
    end

    def taglib_tag
      if @taglib_file.address == 0
        nil
      else
        self.taglib_file_tag(@taglib_file)
      end
    end

    def track_number_from_tag
      if tag = taglib_tag
        track_number = taglib_tag_track(taglib_tag)
        track_number == 0 ? nil : track_number
      end
    end

    def title_from_tag
      if tag = taglib_tag
        title = taglib_tag_title(taglib_tag)
        title.empty? ? nil : title
      end
    end

    def artist_from_tag
      if tag = taglib_tag
        artist = taglib_tag_artist(taglib_tag)
        artist.empty? ? nil : artist
      end
    end

    def album_from_tag
      if tag = taglib_tag
        album = taglib_tag_album(taglib_tag)
        album.empty? ? nil : album
      end
    end

    def genre_from_tag
      if tag = taglib_tag
        genre = taglib_tag_genre(taglib_tag)
        genre.empty? ? nil : genre
      end
    end

    def artist
      artist = artist_from_tag || artist_from_path
      if artist.nil? or artist.empty?
        artist = "Unknown"
      end
      artist
    end

    def album
      album = album_from_tag || album_from_path
      if album.nil? or album.empty?
        album = "Unknown"
      end
      album
    end

    def title
      title = title_from_tag || title_from_path
      if title.nil? or title.empty?
        title = "Unknown"
      end
      title
    end

    def genre
      genre = genre_from_tag
      if genre.nil? or genre.empty?
        genre = "Unknown"
      end
      genre
    end

    def track_number
      number = track_number_from_tag || track_number_from_path
      if number.nil? or number == 0
        number = nil
      end
      number
    end

    # Parses the filepath to extract track information.
    #
    # The method tries a few different regexs.
    def parse(path)
      char_class_definitions = <<-DEF
        (?# <sep> defines a separator between words in the filepath - whitespace or underscore)
        (?<sep> \\s | _){0}

        (?# <chars> defines one or more characters that are used in the title, artist and album name)
        (?<chars> [\\w_\\s!?\\-()'"\\[\\]]+?){0}

        (?# <postnum> defines characters that that could come after the track number)
        (?<postnum> [_\\s\\-\\.]+){0}
      DEF
      # try this sort of structure:
      # artist/album/track
      if %r{
        #{char_class_definitions}

        (?# start with an artist name followed by a directory separator)
        (?<artist>\g<chars>)/

        (?# then comes the album name then the directory separator)
        (?<album>\g<chars>)/ 

        (?# optionally, the track number followed by a <postnum>)
        (?:(?<num>\d{1,2}) \g<postnum>)?

        (?# then the title of the song, followed by a file extension)
        (?<title>\g<chars>) \. \w{3,4}
      }x.match(path) or 
        
      # now try this sort of structure:
      # artist - album/track
      %r{
        #{char_class_definitions}

        (?# start with an artist name followed by a hyphen)
        (?<artist>\g<chars>) \g<sep>? - \g<sep>? 

        (?# then comes the album name then the directory separator)
        (?<album>\g<chars>) / 

        (?# optionally, the track number followed by a <postnum>)
        (?:(?<num>\d{1,2}) \g<postnum>)?

        (?# then the title of the song, followed by a file extension)
        (?<title>\g<chars>) \. \w{3,4}
      }x.match(path) or 
        
      # now try this sort of structure:
      # artist/artist - track
      %r{
        #{char_class_definitions}

        (?# start with an artist name followed by a directory separator)
        (?<artist>\g<chars>)/

        (?# then comes the artist name again followed by a hyphen)
        (?<artist>\g<chars>) \g<sep>? - \g<sep>? 

        (?# optionally, the track number followed by a <postnum>)
        (?:(?<num>\d{1,2}) \g<postnum>)?

        (?# then the title of the song, followed by a file extension)
        (?<title>\g<chars>) \. \w{3,4}
      }x.match(path)
        properties = $~
        @artist_from_path = properties[:artist].gsub("_", " ")

        # album is not always used
        begin
          @album_from_path = properties[:album]
        rescue IndexError
          @album_from_path = nil
        end

        if properties[:num]
          @track_number_from_path = properties[:num].to_i
        else
          @track_number_from_path = nil
        end
        @title_from_path = properties[:title].gsub("_", " ")
      end
    end
  end
end
