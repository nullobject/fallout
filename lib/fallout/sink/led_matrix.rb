require "buccaneer"
require "fallout/marquee"

module Fallout::Sink
  # The LED matrix sink receives messages from sources and displays them.
  # If a message is currently playing while another is received then it
  # is queued for later playback.
  class LEDMatrix < Base
    def initialize
      options = {
        dev:   "/dev/tty.usbserial-A7004HZe",
        mode:  :spi,
        power: true
      }

      @bus_pirate = Bucaneer::BusPirate.connect(options)
      @marquee    = Fallout::Marquee.new(@bus_pirate.protocol)
      @queue      = []

      @marquee.when_finished do |marquee|
        if @queue.any?
          play_message(@queue.shift)
        else
          # TODO: play the game of life or some shit.
        end
      end
    end

    def start
      super
      @marquee.start
    end

    def stop
      @marquee.stop
      @bus_pirate.close
      super
    end

    def notify(message)
      puts "DEBUG: LEDMatrix#notify '#{message}'"
      if @marquee.playing?
        @queue << message
      else
        play_message(message)
      end
    end

  protected
    def play_message(message)
      color =
        if message.is_a?(Fallout::Message::Build)
          case message.status
          when :succeeded
            Fallout::Marquee::GREEN
          when :failed
            Fallout::Marquee::RED
          else
            Fallout::Marquee::WHITE
          end
        else
          Fallout::Marquee::WHITE
        end

      # A single LED matrix is too small to display lower-case letters.
      text = message.to_s.upcase

      @marquee.color = color
      @marquee.start_message(text)
    end
  end
end
