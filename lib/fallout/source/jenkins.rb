require "feedzirra"
require "net/http"

module Fallout::Source
  class Jenkins < Base
    TITLE_RE = /(.+) #(\d+) \((.+)\)/

    def initialize(options = {})
      @host     = options[:host]
      @username = options[:username]
      @password = options[:password]
    end

    def update
      puts "DEBUG: Fallout::Source::Hudson#update"

      xml =
        Net::HTTP.start(@host) do |http|
          request = Net::HTTP::Get.new("/rssLatest")
          request.basic_auth(@username, @password)
          response = http.request(request)
          response.body
        end

      feed = Feedzirra::Feed.parse(xml)

      feed.entries.each do |entry|
        project, build, status = entry.title.match(TITLE_RE).captures

        status =
          case status
          when /^stable$/, /^back to normal$/
            :succeeded
          when /broken/
            :failed
          when /\?/
            :building
          else
            nil
          end

        message = Fallout::Message::Build.new(project, build, status)
        Fallout::Manager.instance.notify(message)
      end
    end
  end
end
