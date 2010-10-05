module Fallout
  module Message
    class Base
      attr_reader :body, :color

      def initialize(body)
        @body = body
      end

      def to_s
        @body
      end
    end
  end
end
