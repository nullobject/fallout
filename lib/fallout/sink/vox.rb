module Fallout::Sink
  class Vox < Base
    def notify(message)
      puts "DEBUG: LEDMatrix#notify '#{message}'"
      `say "#{message}"`
    end
  end
end
