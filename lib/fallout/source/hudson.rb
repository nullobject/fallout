require 'simple-rss'

module Fallout::Source
  class Hudson < Base
    def update
      atom = SimpleRSS.parse(open("/Users/josh/tmp/all.atom"))
      atom.items.each do |entry|
        title = entry.title
        project, build, status = title.scan(/(.+) #(\d+) \((.+)\)/).first
        # TODO: check if build has been displayed before.
        Fallout::Manager.instance.notify(project.upcase)
      end
    end
  end
end
