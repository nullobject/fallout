require 'bucaneer'
require 'cairo'

module Fallout
  # Displays scrolling messages on a LED matrix display.
  # Runs in its own thread and has callbacks for various events.
  class Marquee
    attr_accessor :speed, :dir, :color

    BLACK = [0.0, 0.0, 0.0, 1.0].freeze
    WHITE = [1.0, 1.0, 1.0, 1.0].freeze

    def initialize(options = {})
      @speed  = options[:speed] || 1
      @dir    = options[:dir]   || :right_to_left
      @color  = options[:color] || WHITE
      @x_pos  = 0

      @running = false

      @surface = Cairo::ImageSurface.new(8, 8)
      @context = Cairo::Context.new(@surface)
    end

    def start
      @running = true
      @worker = Thread.new do
        while @running do
          tick
        end
      end
      on_finished
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
        bytes = draw_text(@x_pos, 8)
#         matrix_set_buffer(spi, bytes)
        @x_pos -= 1

        sleep 0.05

        # Has the message finished displaing?
        stop_message if @x_pos < -50
      end
    end

    # Start displaying the given message.
    def start_message(text)
      @current_message = text
      @x_pos = 0
      on_started
    end

    # Stop displaying the current message.
    def stop_message
      @current_message = nil
      @x_pos = 0
      on_finished
    end

    def on_started(&block)
      if block_given?
        @on_started = block
      else
        @on_started.call(self) if @on_started
      end
    end

    def on_finished(&block)
      if block_given?
        @on_finished = block
      else
        @on_finished.call(self) if @on_finished
      end
    end

  private

    def draw_text(x_offset, y_offset)
      @context.set_source_rgba(*BLACK)
      @context.paint

      @context.set_source_rgba(*WHITE)
      @context.select_font_face("monospace", Cairo::FONT_SLANT_NORMAL, Cairo::FONT_WEIGHT_NORMAL)
      @context.set_font_size 10.0
      @context.move_to x_offset, y_offset
      @context.text_path @current_message
      @context.set_line_width 0.125
      @context.set_antialias Cairo::ANTIALIAS_NONE
      @context.fill_preserve
      @context.stroke

      [].tap do |bytes|
        e = @surface.data.enum_for(:each_byte)

        # Re-pack bytes from BGRA -> RGB.
        e.each_slice(4) do |b, g, r, a|
          r = r >> 5
          g = g >> 5
          b = b >> 6
          byte = (r << 5) | (g << 2) | b
          bytes << byte
        end
      end
    end
  end
end
