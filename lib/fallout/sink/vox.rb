module Fallout::Sink
  class Vox < Base
    def notify(message, priority = :normal)
      `say "#{message}"`
    end
  end
end
