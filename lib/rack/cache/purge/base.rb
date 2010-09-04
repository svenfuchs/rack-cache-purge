module Rack
  module Cache
    class Purge
      module Base
        attr_reader :app, :purger

        def initialize(app)
          @app = app
        end

        def call(env)
          purger = Purger.new(env)
          status, headers, body = app.call(env.merge(PURGER_HEADER => purger))
          purger.purge(headers.delete(PURGE_HEADER)) if headers.key?(PURGE_HEADER)
          [status, headers, body]
        end
      end
    end
  end
end