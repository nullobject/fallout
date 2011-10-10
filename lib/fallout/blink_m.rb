module Fallout
  class BlinkM
    ADDRESS     = 0x09
    STOP_SCRIPT = 0x6f
    SET_COLOR   = 0x6e
    FADE_COLOR  = 0x63
    PLAY_SCRIPT = 0x70

    def initialize(i2c)
      @i2c = i2c
    end

    def play_script(n, repeats = 0, offset = 0)
      puts "Playing BlinkM script ##{n}"
      @i2c.tx(ADDRESS, PLAY_SCRIPT, n, repeats, offset)
    end

    def stop_script
      puts "Stopping BlinkM script"
      @i2c.tx(ADDRESS, STOP_SCRIPT)
    end

    def set_color(r, g, b, fade = false)
      puts "Setting color #%.2x%.2x%.2x" % [r, g, b]
      command = fade ? FADE_COLOR : SET_COLOR
      @i2c.tx(ADDRESS, command, r, g, b)
    end
  end
end
