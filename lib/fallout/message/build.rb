module Fallout
  module Message
    class Build < Base
      attr_reader :project, :build, :status

      def initialize(project, build, status)
        @project = project
        @build   = build
        @status  = status
      end

      def to_s
        "#{@project} #{@status}"
      end
    end
  end
end
