require "#{File.dirname(__FILE__)}/test_setup"
require 'rack/cache/purge'

describe 'Rack::Cache::Purge' do
  before(:each) { setup_cache_context }
  after(:each)  { teardown_cache_context }

  it 'purges entries on PURGE requests' do
    respond_with 200, { 'Cache-Control' => 'public, max-age=10000', 'ETag' => '12345' }, 'body'
    get '/'
    cache.trace.should.include :store

    get '/'
    cache.trace.should.include :fresh

    @app = lambda { |env| fail('app should not be called') }
    request 'purge', '/'

    respond_with 200, { 'Cache-Control' => 'public, max-age=10000', 'ETag' => '12345' }, 'body'
    get '/'
    cache.trace.should.include :miss
  end

  # %w(get post put delete).each do |request_method|
  %w(get).each do |request_method|
    it 'purges entries specified through X-Cache-Purge headers on #{request_method} requests' do
      respond_with 200, { 'Cache-Control' => 'public, max-age=500' }, 'body' do |req, res|
        if req.path == '/foo'
          res.headers['X-Cache-Purge'] = ['/']
        else
          res.headers.delete('X-Cache-Purge')
        end
      end
  
      get '/'
      cache.trace.should.include :store
  
      get '/'
      cache.trace.should.include :fresh
  
      request request_method, '/foo'
      get '/'
      cache.trace.should.include :miss
    end
  end
end