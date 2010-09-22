require 'cairo'

module Fallout
  # Displays scrolling messages on a LED matrix display.
  # Runs in its own thread and has callbacks for various events.
  class Marquee
    LEFT_TO_RIGHT =  1
    RIGHT_TO_LEFT = -1

    WIDTH  = 8
    HEIGHT = 8

    FONT_FACE = "monospace"
    FONT_SIZE = 10.0

    BLACK = [0.0, 0.0, 0.0].freeze
    WHITE = [1.0, 1.0, 1.0].freeze

    attr_accessor :speed, :dir, :color
    attr_reader :current_message, :x_pos, :text_extents

    def initialize(spi, options = {})
      @spi = spi

      @delay = options[:delay] || 0.05
      @dir   = options[:dir]   || RIGHT_TO_LEFT
      @color = options[:color] || WHITE

      init_surface
    end

    def start
      @running = true
      @worker = Thread.new do
        while @running do
          tick
        end
      end
      when_finished
    end

    def stop
      if @running
        @running = false
        @worker.join
        @worker = nil
      end
    end

    def tick
      if @current_message
        clear
        draw_text(@x_pos, HEIGHT)
        @spi.tx(surface_data)

        @x_pos += @dir

        sleep @delay

        finish_message if finished?
      end
    end

    # Start displaying the given message.
    def start_message(text)
      puts "DEBUG: start_message '#{text}'"
      set_current_message(text)
      when_started
    end

    # Stop displaying the current message.
    def finish_message
      puts "DEBUG: finish_message"
      @current_message = nil
      when_finished
    end

    def when_started(&block)
      if block_given?
        @when_started = block
      else
        @when_started.call(self) if @when_started
      end
    end

    def when_finished(&block)
      if block_given?
        @when_finished = block
      else
        @when_finished.call(self) if @when_finished
      end
    end

  private

    def init_surface
      @surface = Cairo::ImageSurface.new(WIDTH, HEIGHT)
      @context = Cairo::Context.new(@surface)

      @context.select_font_face(FONT_FACE, Cairo::FONT_SLANT_NORMAL, Cairo::FONT_WEIGHT_NORMAL)
      @context.set_font_size(FONT_SIZE)
    end

    def clear
      @context.set_source_rgb(*BLACK)
      @context.paint
    end

    def draw_text(x_offset, y_offset)
      @context.set_source_rgb(*@color)
      @context.move_to(x_offset, y_offset)

#       @context.show_text(@current_message)

      @context.text_path(@current_message)
      @context.set_line_width(0.125)
      @context.set_antialias(Cairo::ANTIALIAS_NONE)
      @context.fill_preserve
      @context.stroke
    end

    def surface_data
      [].tap do |bytes|
        e = @surface.data.enum_for(:each_byte)

        e.each_slice(4) do |b, g, r, a|
          r = r >> 5 # reduce R to 3-bits
          g = g >> 5 # reduce G to 3-bits
          b = b >> 6 # reduce B to 2-bits

          # Pack the bits RRRGGGBB.
          byte = (r << 5) | (g << 2) | b

          bytes << byte
        end
      end
    end

    def set_current_message(text)
      @text_extents = @context.text_extents(text)
      set_initial_x_pos
      @current_message = text
    end

    def set_initial_x_pos
      if @dir > 0
        @x_pos = -@text_extents.width.to_i
      else
        @x_pos = WIDTH
      end
    end

    # Returns true if we've moved past the last character in the message.
    def finished?
      if @dir > 0
        @x_pos > WIDTH
      else
        @x_pos < -@text_extents.width.to_i
      end
    end
  end
end
