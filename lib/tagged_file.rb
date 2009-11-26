#!/scratch/bin/ruby
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
      self.taglib_file_tag(@taglib_file)
    end

    def track_number_from_tag
      taglib_tag_track(taglib_tag)
    end

    def title_from_tag
      taglib_tag_title(taglib_tag)
    end

    def artist_from_tag
      taglib_tag_artist(taglib_tag)
    end

    def album_from_tag
      taglib_tag_album(taglib_tag)
    end

    def genre_from_tag
      taglib_tag_genre(taglib_tag)
    end

    def artist
      artist_from_tag || artist_from_path || "Unknown"
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
