require "#{File.dirname(__FILE__)}/test_setup"
require 'rack/cache/purge'

describe 'Rack::Cache::Purge' do
  before(:each) { setup_cache_context }
  after(:each)  { teardown_cache_context }

  it 'sets allow_http_purge to false by default' do
    Rack::Cache::Purge.new(nil).allow_http_purge?.should.be false
  end

  it 'can set allow_http_purge to true' do
    Rack::Cache::Purge.new(nil, :allow_http_purge => true).allow_http_purge?.should.be true
  end

  it 'purges entries on PURGE requests' do
    respond_with 200, { 'Cache-Control' => 'public, max-age=10000' }, 'body'

    get '/'
    cache.trace.should.include :store

    get '/'
    cache.trace.should.include :fresh

    request 'purge', '/'
    cache.trace.should.include :pass
    app.called?.should == false

    get '/'
    cache.trace.should.include :miss
  end

  %w(get post put delete).each do |request_method|
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

      request request_method, '/foo' # returns X-Cache-Purge for "/"

      get '/'
      cache.trace.should.include :miss
    end
  end

  it 'allows downstream apps to purge entries using env["rack-cache.purger"]' do
    respond_with 200, { 'Cache-Control' => 'public, max-age=10000' }, 'body' do |req, res|
      if req.path == '/foo'
        req.env["rack-cache.purger"].purge('/')
      end
    end

      get '/'
      cache.trace.should.include :store

      get '/'
      cache.trace.should.include :fresh

      post '/foo' # manually purges using env["rack-cache.purger"]

      get '/'
      cache.trace.should.include :miss
  end
end