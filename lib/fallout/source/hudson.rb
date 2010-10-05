require 'open-uri'
require 'redis'
require 'simple-rss'

module Fallout::Source
  class Hudson < Base
    FEED_URL = "http://cruisectl.clearholdings.com.au:8080/rssLatest".freeze

    def initialize
      @redis = Redis.new
    end

    def update
      puts "DEBUG: Fallout::Source::Hudson#update"
      atom = SimpleRSS.parse(open(FEED_URL))
      atom.items.each do |entry|
        id = entry.title
        unless @redis.sismember("builds", id)
          project, build, status = id.scan(/(.+) #(\d+) \((.+)\)/).first
          status =
            case status.downcase
            when "success"
              :succeeded
            when "failure"
              :failed
            when "null"
              :started
            else
              nil
            end
          message = Fallout::Message::Build.new(project, build, status)
          Fallout::Manager.instance.notify(message)
          @redis.sadd("builds", id)
        end
      end
    end
  end
end
