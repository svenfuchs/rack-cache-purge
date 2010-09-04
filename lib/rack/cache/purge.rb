module Rack
  module Cache
    class Purge
      class << self
        def allow_http_purge!
          include Rack::Cache::Purge::Http
        end
      end
      
      PURGE_HEADER  = 'rack-cache.purge'
      PURGER_HEADER = 'rack-cache.purger'

      autoload :Base,   'rack/cache/purge/base'
      autoload :Http,   'rack/cache/purge/http'
      autoload :Purger, 'rack/cache/purge/purger'
      
      include Base
    end
  end
end