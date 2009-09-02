require 'uri'
require 'rack/cache'
require 'rack/cache/storage'
require 'rack/cache/tools'

module Rack::Cache::Purge
  autoload :Context, 'rack/cache/purge/context'
  autoload :Purger,  'rack/cache/purge/purger'

  PURGE_HEADER = 'X-Cache-Purge'

  def self.new(backend, options={}, &b)
    Context.new(backend, options, &b)
  end
end