# Copyright (C) 2009 Mark Somerville <mark@scottishclimbs.com>
# Released under the General Public License (GPL) version 3.
# See COPYING

require 'ffi'

module MusicImporter
  class MusicFile
    attr_reader :title_from_path, :artist_from_path, :album_from_path, :track_number_from_path, :taglib_file

    extend FFI::Library
    ffi_lib "tag_c"
    attach_function :taglib_file_new, [ :string ], :pointer
    attach_function :taglib_file_tag, [ :pointer ], :pointer
    attach_function :taglib_tag_track, [ :pointer ], :uint
    attach_function :taglib_tag_title, [ :pointer ], :string
    attach_function :taglib_tag_artist, [ :pointer ], :string
    attach_function :taglib_tag_album, [ :pointer ], :string
    attach_function :taglib_tag_genre, [ :pointer ], :string
    attach_function :taglib_tag_free_strings, [], :void
    attach_function :taglib_file_free, [ :pointer ], :void

    # Defines some named matches for use when parsing the filepath.
    CHAR_CLASS_DEFINITIONS = <<-DEF
      (?# <sep> defines a separator between words in the filepath - whitespace or underscore)
      (?<sep> \\s | _){0}

      (?# <chars> defines one or more characters that are used in the title, artist and album name)
      (?<chars> [\\w_\\s!?\\-()'"\\[\\]]+?){0}

      (?# <postnum> defines characters that that could come after the track number)
      (?<postnum> [_\\s\\-\\.]+){0}
    DEF

    def initialize(path, collection_root)
      collection_root = "#{collection_root}/" unless collection_root.empty?
      @path = path
      parse path
      @taglib_file = taglib_file_new("#{collection_root}#{@path}")
      if @taglib_file.address == 0
        @taglib_tag = nil
      else
        @taglib_tag = self.taglib_file_tag(@taglib_file)
      end
    end

    # Called with a block, this will create a MusicFile and handle freeing 
    # resources when the block has finished.
    def self.open(path, collection_root = "", &block)
      instance = new(path, collection_root)
      yield instance
      instance.free_resources
    end

    # Frees the memory used the TagLib C stuff. This will make calling some
    # methods on the object throw errors.
    #
    # TODO: if an instance has had this method called on it, auto-initialize
    # the TagLib stuff again so that those methods can be called safely.
    def free_resources
      taglib_tag_free_strings
      taglib_file_free @taglib_file
      # calling this every time resources are freed is slow, but minimises 
      # memory usage
      GC.start 
    end

    # Returns the track number from the tag. Returns nil if not known.
    def track_number_from_tag
      if @taglib_tag
        track_number = taglib_tag_track(@taglib_tag)
        track_number == 0 ? nil : track_number
      end
    end

    # Returns the title from the tag. Returns nil if not known.
    def title_from_tag
      if @taglib_tag
        title = taglib_tag_title(@taglib_tag)
        title.empty? ? nil : title
      end
    end

    # Returns the artist from the tag. Returns nil if not known.
    def artist_from_tag
      if @taglib_tag
        artist = taglib_tag_artist(@taglib_tag)
        artist.empty? ? nil : artist
      end
    end

    # Returns the album from the tag. Returns nil if not known.
    def album_from_tag
      if @taglib_tag
        album = taglib_tag_album(@taglib_tag)
        album.empty? ? nil : album
      end
    end

    # Returns the genre from the tag. Returns nil if not known.
    def genre_from_tag
      if @taglib_tag
        genre = taglib_tag_genre(@taglib_tag)
        genre.empty? ? nil : genre
      end
    end

    # Returns the artist from the tag, falling back to the path and, finally,
    # "Unknown".
    def artist
      artist = artist_from_tag || artist_from_path
      if artist.nil? or artist.empty?
        artist = "Unknown"
      end
      artist
    end

    # Returns the album from the tag, falling back to the path and, finally,
    # "Unknown".
    def album
      album = album_from_tag || album_from_path
      if album.nil? or album.empty?
        album = "Unknown"
      end
      album
    end

    # Returns the title from the tag, falling back to the path and, finally,
    # "Unknown".
    def title
      title = title_from_tag || title_from_path
      if title.nil? or title.empty?
        title = "Unknown"
      end
      title
    end

    # Returns the genre from the tag, falling back to the path and, finally,
    # "Unknown".
    def genre
      genre = genre_from_tag
      if genre.nil? or genre.empty?
        genre = "Unknown"
      end
      genre
    end

    # Returns the track number from the tag, falling back to the path and,
    # finally, nil.
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
      # try this sort of structure:
      # artist/album/track
      if %r{
        #{CHAR_CLASS_DEFINITIONS}

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
        #{CHAR_CLASS_DEFINITIONS}

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
        #{CHAR_CLASS_DEFINITIONS}

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
