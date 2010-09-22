module Fallout::Sink
  class Base
    attr_accessor :manager

    def start
    end

    def stop
    end

    def notify(message, priority = :normal)
    end
  end
end
