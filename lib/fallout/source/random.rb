module Fallout::Source
  class Random < Base
    def update
      @manager.notify("HELLO WORLD!")
    end
  end
end
