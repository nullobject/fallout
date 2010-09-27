module Fallout::Sink
  class Base
    def start
    end

    def stop
    end

    def notify(message, priority = :normal)
    end
  end
end
