require 'uri'
require 'rack/cache'
require 'rack/cache/storage'
require 'rack/cache/utils'

module Rack::Cache
  PURGE_HEADER = 'X-Cache-Purge'

  module Purge
    autoload :Context, 'rack/cache/purge/context'
    autoload :Purger,  'rack/cache/purge/purger'

    def self.new(backend, options={}, &b)
      Context.new(backend, options, &b)
    end
  end
end