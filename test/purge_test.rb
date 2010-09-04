require File.expand_path('../test_helper', __FILE__)

class PurgeTest < Test::Unit::TestCase
  test 'downstream apps can purge entries through "rack-cache.purge" headers' do
    respond_with do |request, response|
      case request.url
      when 'http://example.com/foo'
        response.headers.merge!('Cache-Control' => 'public, max-age=500')
      when 'http://example.com/purging'
        response.headers.merge!(Rack::Cache::Purge::PURGE_HEADER => ['http://example.com/foo'])
      end
    end
    
    get 'http://example.com/foo'
    assert_cached 'http://example.com/foo'

    get 'http://example.com/purging'
    assert_not_cached 'http://example.com/foo'
  end

  test 'downstream apps can purge entries using env["rack-cache.purger"]' do
    respond_with do |request, response|
      case request.url
      when 'http://example.com/foo'
        response.headers.merge!('Cache-Control' => 'public, max-age=500')
      when 'http://example.com/purging'
        request.env['rack-cache.purger'].purge('http://example.com/foo')
      end
    end
    
    get 'http://example.com/foo'
    assert_cached 'http://example.com/foo'

    get 'http://example.com/purging'
    assert_not_cached 'http://example.com/foo'
  end
end