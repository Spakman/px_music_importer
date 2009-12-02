require 'gst'

module MusicImporter
  class MusicImporter::SupportChecker
    # Returns if a file is supported by our audio system.
    #
    # This will return true for video files that have an audio track.
    #
    # This feels rather brute force and there is likely to be a nicer (shorter,
    # faster) way to check, but I don't know what it is.
    def supported?(filepath)
      @supported = false
      # it would be better if this was using playbin2, but that causes hangs sometimes when stopping the playbin.
      @playbin = Gst::ElementFactory.make('playbin')
      @playbin.uri = "file:///#{File.expand_path(filepath)}"
      @playbin.ready
      @loop = GLib::MainLoop.new(nil, false)
      @playbin.audio_sink = Gst::ElementFactory.make('autoaudiosink')

      @playbin.bus.add_watch do |bus, message| 
        case message.type
        when Gst::Message::TAG
          @supported = true
          @loop.quit
        when Gst::Message::EOS, Gst::Message::ERROR
          @supported = false
          @loop.quit
        end
        true
      end

      begin
        @playbin.play
        @loop.run
      ensure
        @playbin.stop
      end
      return @supported
    end
  end
end
