module Fallout
  class Manager
    def initialize
      @sources = []
      @sinks   = []
      super() # NOTE: This *must* be called, otherwise states won't get initialized.
    end

    def run
      start
      @worker.join
    end

    def start
      @sources.map(&:start)
      @sinks.map(&:start)

      @running = true

      @worker = Thread.new do
        while @running
          @sources.map(&:update)
          sleep 60
        end
      end
    end

    def stop
      @sinks.map(&:stop)
      @sources.map(&:stop)
      @running = false
      @worker.wakeup
    end

    def add_source(source)
      source.manager = self
      @sources << source
    end

    def add_sink(sink)
      sink.manager = self
      @sinks << sink
    end

    def notify(message)
      return unless @running
      puts "DEBUG Manager#notify '#{message}'"
      @sinks.each {|sink| sink.notify(message) }
    end
  end
end
