require "buccaneer"
require "fallout/blink_m"

module Fallout::Sink
  class BuildIndicator < Base
    RED_FLASH   = 3
    GREEN_FLASH = 4

    def initialize(options = {})
      options = {
        mode:    :i2c,
        power:   :on,
        pullups: :on
      }.update(options)

      @bus_pirate = Bucaneer::BusPirate.connect(options)
      @blink_m    = Fallout::BlinkM.new(@bus_pirate.protocol)

      @blink_m.stop_script

      @projects = options[:projects]
    end

    def stop
      @bus_pirate.close
      super
    end

    def notify(message)
      puts "DEBUG: BuildIndicator#notify '#{message}'"

      if message.is_a?(Fallout::Message::Build)
        if @projects.include?(message.project)
          case message.status
          when :succeeded
            @blink_m.stop_script
            @blink_m.set_color(0, 0xff, 0, true)
          when :failed
            @blink_m.stop_script
            @blink_m.set_color(0xff, 0, 0, true)
          when :building
            @blink_m.play_script(GREEN_FLASH)
          end
        end
      end
    end
  end
end
