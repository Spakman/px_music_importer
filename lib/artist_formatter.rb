# Copyright (C) 2009 Mark Somerville <mark@scottishclimbs.com>
# Released under the General Public License (GPL) version 3.
# See COPYING

module ArtistFormatter
  def self.format_for_consistency(artist)
    artist.sub!(/, the$/i, "")
    artist.sub!(/^the /i, "")
    artist.gsub!(/\./, "")
    artist.gsub!(/\sand\s/i, " & ")
    artist.sub!(/(^|\s)d\.?j\.?/i, '\1DJ')
    artist.sub!(/\sfeat(?:uring|\.)?\s.+$/i, "")
    artist.sub!(/\s(?:vs\.?|versus)\s.+$/i, "")
    artist
  end
end
