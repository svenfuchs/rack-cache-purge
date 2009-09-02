require "#{File.dirname(__FILE__)}/test_setup"
require 'rack/cache/tools/key'

module TestKeyHelpers
  def request(*args)
    uri, opts = args
    env = Rack::MockRequest.env_for(uri, opts || {})
    Rack::Cache::Request.new(env)
  end

  def key(*args)
    Rack::Cache::Tools::Key.call(*args)
  end
end

describe 'A Rack::Cache::Key' do
  describe 'with a Rack::Request' do
    include TestKeyHelpers
    
    it "sorts params" do
      request = request('/test?z=last&a=first')
      key(request).should.include('a=first&z=last')
    end

    it "includes the scheme" do
      request = request('/test', 'rack.url_scheme' => 'https', 'HTTP_HOST' => 'example.org')
      key(request).should.include('https://')
    end

    it "includes host" do
      request = request('/test', "HTTP_HOST" => 'www2.example.org')
      key(request).should.include('www2.example.org')
    end

    it "includes path" do
      request = request('/test')
      key(request).should.include('/test')
    end

    it "sorts the query string by key/value after decoding" do
      request = request('/test?x=q&a=b&%78=c')
      key(request).should.match(/\?a=b&x=c&x=q$/)
    end

    it "is in order of scheme, host, path, params" do
      request = request('/test?x=y', "HTTP_HOST" => 'www2.example.org')
      key(request).should.equal "http://www2.example.org/test?x=y"
    end
  end

  describe 'with an uri String' do
    include TestKeyHelpers
    
    it "expands a relative uri" do
      request = request('/foo', 'rack.url_scheme' => 'http', 'HTTP_HOST' => 'example.org')
      uri = '/test'
      key(request, uri).should.include('http://example.org/test')
    end
    
    it "sorts params" do
      request = request('/foo')
      uri = '/test?z=last&a=first'
      key(request, uri).should.include('a=first&z=last')
    end

    it "includes the scheme" do
      request = request('/test', 'rack.url_scheme' => 'http', 'HTTP_HOST' => 'example.org')
      uri = 'https://www2.example.org/test'
      key(request, uri).should.include('https://')
    end

    it "includes host" do
      request = request('/test', "HTTP_HOST" => 'www.example.org')
      uri = 'https://www2.example.org/test'
      key(request, uri).should.include('www2.example.org')
    end

    it "includes path" do
      request = request('/test')
      uri = '/test2'
      key(request, uri).should.include('/test2')
    end

    it "sorts the query string by key/value after decoding" do
      request = request('/test')
      uri = '/test?x=q&a=b&%78=c'
      key(request, uri).should.match(/\?a=b&x=c&x=q$/)
    end

    it "is in order of scheme, host, path, params" do
      request = request('/test')
      uri = "http://www2.example.org/test2?x=y"
      key(request, uri).should.equal "http://www2.example.org/test2?x=y"
    end
  end
end

