require 'gst'

module MusicImporter
  class MusicImporter::SupportChecker
    def initialize
      @loop = GLib::MainLoop.new(nil, false)
      @pipeline = Gst::Pipeline.new

      # The sole job is to catch messages, set the @supported state and immediately quit the loop.
      @pipeline.bus.add_watch do |bus, message|
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
    end

    # Returns if a file is supported by our audio system.
    #
    # This will return true for video files that have an audio track.
    #
    # This feels rather brute force and there is likely to be a nicer (shorter,
    # faster) way to check, but I don't know what it is.
    def supported?(filepath)
      @supported = false
      decoder = Gst::ElementFactory.make("decodebin")
      audio_convert = Gst::ElementFactory.make("audioconvert")
      audio_resample = Gst::ElementFactory.make("audioresample")
      audio_sink = Gst::ElementFactory.make("autoaudiosink")
      file_src = Gst::ElementFactory.make("filesrc")
      file_src.location = filepath
      @pipeline.add(file_src, decoder, audio_convert, audio_resample, audio_sink)
      file_src >> decoder
      audio_convert >> audio_resample >> audio_sink
      begin
        @pipeline.play
        @loop.run
      ensure
        @pipeline.stop
      end
      return @supported
    end
  end
end
