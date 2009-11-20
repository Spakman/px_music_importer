#!/scratch/bin/ruby
require 'ffi'

module MusicImporter
  class TaggedFile
    extend FFI::Library
    ffi_lib "tag_c"
    attach_function :taglib_file_new, [ :string ], :pointer
    attach_function :taglib_file_tag, [ :pointer ], :pointer
    attach_function :taglib_tag_track, [ :pointer ], :uint
    attach_function :taglib_tag_title, [ :pointer ], :string
    attach_function :taglib_tag_artist, [ :pointer ], :string
    attach_function :taglib_tag_album, [ :pointer ], :string
    attach_function :taglib_tag_genre, [ :pointer ], :string

    def initialize(path)
      @path = path
      @taglib_file = taglib_file_new(@path)
    end

    def self.open(path)
      new path
    end

    def taglib_tag
      self.taglib_file_tag(@taglib_file)
    end

    def track_number
      taglib_tag_track(taglib_tag)
    end

    def title
      taglib_tag_title(taglib_tag)
    end

    def artist
      taglib_tag_artist(taglib_tag)
    end

    def album
      taglib_tag_album(taglib_tag)
    end

    def genre
      taglib_tag_genre(taglib_tag)
    end
  end
end
