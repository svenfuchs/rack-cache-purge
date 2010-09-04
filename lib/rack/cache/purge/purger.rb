require 'rack/cache/key'
require 'rack/mock'

module Rack
  module Cache
    class Purge
      class Purger
        attr_reader :env

        def initialize(env)
          @env = env
        end

        def purge(uris)
          normalize_uris(uris).map do |uri|
            key = key_for(uri)
            metastore.purge(key)
            entitystore.purge(key)
          end
        end

        protected

          def normalize_uris(uris)
            Array(uris).flatten.join("\n").split("\n")
          end

          def key_for(uri)
            Rack::Cache::Key.call(Rack::Cache::Request.new(env_for(uri)))
          end

          def env_for(*args)
            Rack::MockRequest.env_for(*args)
          end
        
          def metastore
            @metastore ||= Rack::Cache::Storage.instance.resolve_metastore_uri(env['rack-cache.metastore'])
          end
        
          def entitystore
            @entitystore ||= Rack::Cache::Storage.instance.resolve_entitystore_uri(env['rack-cache.entitystore'])
          end
      end

      include Base
    end
  end
end