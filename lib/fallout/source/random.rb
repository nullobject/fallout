module Fallout::Source
  class Random < Base
    def update
      Fallout::Manager.instance.notify("HELLO WORLD!")
    end
  end
end
