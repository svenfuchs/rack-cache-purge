module Rack
  module Cache
    class Purge
      module Http
        def call(env)
          http_purge?(env) ? http_purge(env) : super
        end
        
        protected

          def http_purge?(env)
            env['REQUEST_METHOD'] == 'PURGE'
          end
          
          def http_purge(env)
            Purger.new(env).purge(Rack::Request.new(env).url)
            [200, {}, 'Purged']
          end
      end
    end
  end
end