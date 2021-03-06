require "singleton"

module Fallout
  class Manager
    TIMEOUT = 10

    include Singleton

    attr_reader :sources, :sinks

    def initialize
      @sources = []
      @sinks   = []
    end

    def run
      start
      @worker.join
    end

    def start
      puts "DEBUG: Manager#start"

      @sources.map(&:start)
      @sinks.map(&:start)

      @running = true

      @worker = Thread.new do
        while @running
          @sources.map(&:update)
          sleep TIMEOUT
        end
      end
    end

    def stop
      puts "DEBUG: Manager#stop"

      @sources.map(&:stop)
      @sinks.map(&:stop)

      @running = false

      @worker.wakeup
    end

    def notify(message)
      puts "DEBUG: Manager#notify '#{message}'"
      @sinks.each {|sink| sink.notify(message) }
    end
  end
end
