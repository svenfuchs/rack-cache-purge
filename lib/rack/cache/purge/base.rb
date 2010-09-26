module Rack
  module Cache
    class Purge
      module Base
        attr_reader :app, :purger

        def initialize(app, options = {})
          self.class.allow_http_purge! if options[:allow_http_purge]
          @app = app
        end

        def call(env)
          purger = Purger.new(env)
          status, headers, body = app.call(env.merge(PURGER_HEADER => purger))

          # TODO we probably should remove the headers here but i can't figure out
          # how to get the middlewares correctly pushed to the rails middleware stack
          # purger.purge(headers.delete(PURGE_HEADER)) if headers.key?(PURGE_HEADER)

          purger.purge(headers[PURGE_HEADER]) if headers.key?(PURGE_HEADER)
          [status, headers, body]
        end
      end
    end
  end
end