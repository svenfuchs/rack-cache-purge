$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'test/unit'
require 'test_declarative'
require 'fileutils'
require 'ruby-debug'
require 'rack/cache'
require 'rack_cache_purge'

class Test::Unit::TestCase
  attr_reader :app
  
  def respond_with(status = 200, headers = {}, body = '')
    @app = Rack::Cache::Context.new(Rack::Cache::Purge.new(lambda { |env|
      request  = Rack::Request.new(env)
      response = Rack::Response.new(body, status, headers)
      yield request, response if block_given?
      response.finish
    }, :allow_http_purge => true))
  end
  
  def get(url)
    app.call(env_for(url))
  end
  
  def purge(url)
    app.call(env_for(url, 'REQUEST_METHOD' => 'PURGE'))
  end
  
  def assert_cached(uri)
    assert metastore.lookup(request_for(uri), entitystore), "Expected #{uri} to be cached, but it isn't."
  end
  
  def assert_not_cached(uri)
    assert metastore.lookup(request_for(uri), entitystore).nil?, "Expected #{uri} not to be cached, but it is."
  end
  
  def metastore
    Rack::Cache::Storage.instance.resolve_metastore_uri('heap:/')
  end
  
  def entitystore
    Rack::Cache::Storage.instance.resolve_entitystore_uri('heap:/')
  end
  
  def request_for(uri, options = {})
    Rack::Request.new(env_for(uri).merge(options))
  end
  
  def env_for(*args)
    Rack::MockRequest.env_for(*args)
  end
end